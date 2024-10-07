#/bin/bash
# from https://github.com/blackrosezy/django-startup


PROJECTNAME=demo

if [ $# -gt 0 ]; then
	PROJECTNAME=$1
fi

type unzip >/dev/null 2>&1 || {
        echo " => Installing unzip..."
        apt-get install -y unzip
}

type rpl >/dev/null 2>&1 || {
        echo " => Installing rpl..."
        apt-get install -y rpl
}

type python >/dev/null 2>&1 || { 
        echo " => Installing python..."
	apt-get install -y python
}

type pip >/dev/null 2>&1 || {
        echo " => Installing pip..."
       	wget https://bootstrap.pypa.io/get-pip.py 
	python get-pip.py
}

type virtualenv  >/dev/null 2>&1 || {
	echo " => Installing virtualenv..."
	pip install virtualenv
}

echo " => Removing old virtual environment..."
rm -rf env-$PROJECTNAME

echo " => Creating a new virtual environment..."
virtualenv env-$PROJECTNAME
source env-$PROJECTNAME/bin/activate

echo " => Installing Django..."
pip install django

echo " => Removing old Django project..."
rm -rf "$PROJECTNAME"_project

echo " => Creating a new Django project..."
django-admin startproject "$PROJECTNAME"_project
pushd "$PROJECTNAME"_project

echo " => Creating static directory..."
mkdir static
pushd static

echo " => Downloading Zurb Foundation..."
curl -o foundation.zip  http://foundation.zurb.com/cdn/releases/foundation-5.4.7.zip
unzip -q foundation.zip
rm foundation*.zip *.txt

echo " => Downloading Font Awesome..."
curl -o font-awesome.zip http://fortawesome.github.io/Font-Awesome/assets/font-awesome-4.2.0.zip
unzip -q font-awesome.zip
pushd font-awesome*
rm -rf less scss
cp -rf * ..
popd
rm -rf font-awesome*

# exit from static directory
popd

echo " => Creating startup app..."
python manage.py startapp $PROJECTNAME
mkdir $PROJECTNAME/templates
mv static/index.html $PROJECTNAME/templates

echo " => Updating urls.py..."
pushd "$PROJECTNAME"_project

# Add import
new_string="from django.contrib import admin

from $PROJECTNAME.views import HomeView"

rpl -qed "from django.contrib import admin" "$new_string" urls.py

# Add routes
new_string="url(r'^$', HomeView.as_view(), name='home'),
    url(r'^admin/', include(admin.site.urls)),"
rpl -qed "url(r'^admin/', include(admin.site.urls))," "$new_string" urls.py

echo " => Updating settings.py..."
new_string="STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'static'),
)"
rpl -qed "STATIC_URL = '/static/'" "$new_string" settings.py

popd

echo " => Updating index.html"
pushd $PROJECTNAME/templates
new_string="{% load static %}
<!doctype html>"
rpl -qed "<!doctype html>" "$new_string" index.html 

rpl -qed "css/" '{% static "css/' index.html
rpl -qed ".css" '.css" %}' index.html

rpl -qed "js/" '{% static "js/' index.html
rpl -qed ".js" '.js" %}' index.html
popd

echo " => Updating views.py" 
new_string='from django.views.generic import TemplateView

class HomeView(TemplateView):
    template_name = "index.html"'
echo "$new_string" > $PROJECTNAME/views.py


echo " => Creating requirements.txt..."
pip freeze > requirements.txt
