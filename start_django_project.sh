#!/bin/bash
#
# Luca Buoncristiani 2024
# released with MIT License




# Script per la generazione di un ambiente di sviluppo django
# ed il suo virtualenv



# Creazione cartella di lavoro
mkdir output
cd output


# Variables
# PROJECT=${1-myproject}
APACHE_LOG_DIR=/var/log/apache2
WEB_PORT=80

DJANGO_PROJECT_NAME="djangocbutemplate"
VENV_NAME=".venv"


# Variables
ROOT_DIR="$PWD"
SITENAME="backend"
TEMPLATE_NAME="djangocbutemplate"
HOMEDIR="${ROOT_DIR}/${TEMPLATE_NAME}/"


# Colors
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`


# check for root
if [[ "$(id -u)" == "0" ]]; then
    echo -e "${red}\n* Errore: Eseguire lo script come non-root. "
    echo -e "${red}* Don't be a superuser, be supernatural.        (Luca 4,11)\n*\n"
    exit 1
fi

# Pulizia schermo
clear 

# Messaggio di benvenuto
echo "${red}+------ Buoncri's Django Project Generator ------+"
echo "${red}|                                                |"   
echo "${red}| ${reset}Creazione di un ambiente di sviluppo Django${red}    |"
echo "${red}|                                                |"
echo "${red}+------------------------------------------------+"
echo "${reset}"

echo "${red}ATTUALE [$PWD]"
echo "${green} ROOT_DIR = $ROOT_DIR"
echo "${green} SITENAME = $SITENAME"
echo "${green} TEMPLATE_NAME = $TEMPLATE_NAME"
echo "${green} HOMEDIR = $HOMEDIR"

SETTINGS_PY_FILE="${ROOT_DIR}/${TEMPLATE_NAME}/${SITENAME}/settings.py"
echo "${green} SETTINGS: ${SETTINGS_PY_FILE} ${reset}"


sleep 1

echo "${red}+------------------------------------------------+${reset}"

# Creazione cartella ambiente sviluppo
echo "${green}>>> Creazione cartella sviluppo ${DJANGO_PROJECT_NAME}${reset} ... |"
mkdir .venv
echo

# Creo il virtualenv
echo "${green}>>> Creazione ambiente di sviluppo ... ${reset}"
pipenv install django # black isort djlint psycopg
echo


# Creazione cartella del progetto
echo "${green}>>> Creazione cartella del progetto ${TEMPLATE_NAME}${reset}"
mkdir "${TEMPLATE_NAME}"
mkdir "${TEMPLATE_NAME}/media"
mkdir "${TEMPLATE_NAME}/static"
mkdir "${TEMPLATE_NAME}/templates"

# mkdir "${TEMPLATE_NAME}/doc"
# mkdir "${TEMPLATE_NAME}/tests"
touch "${TEMPLATE_NAME}/static/styles.css"

echo "Creazione cartella del progetto ${TEMPLATE_NAME} ... OK"


# Creo il progetto django
echo "${green}>>> Creazione progetto Django ... ${reset}"
cd ${TEMPLATE_NAME} || die "Errore: cartella ${TEMPLATE_NAME} non esiste"
pipenv run django-admin startproject backend .
echo "Creazione progetto ... OK"


# Creo l'applicazione api
echo "${green}>>> Creazione app API ... ${reset}"
pipenv run ./manage.py startapp api
echo "Creazione app API ... OK"


# Creo l'applicazione layout
echo "${green}>>> Creazione app layout ... ${reset}"
pipenv run ./manage.py startapp layout
echo "Creazione app layout ... OK"
cd ..


# Creo il file requirements.txt
echo "${green}>>> Creazione file requirements.txt ... ${reset}"
pipenv requirements > requirements.txt
echo "Creazione file requirements.txt ... OK"


# Creo il file .gitignore
echo "${green}>>> Creazione file .gitignore ... ${reset}"
echo ".venv" > .gitignore
echo "__pycache__" >> .gitignore
echo "db.sqlite3" >> .gitignore
echo "media" >> .gitignore
echo "static" >> .gitignore
echo "node_modules" >> .gitignore
echo "yarn-error.log" >> .gitignore
echo ".DS_Store" >> .gitignore
echo ".env" >> .gitignore
echo "env" >> .gitignore
echo "migrations" >> .gitignore
echo "Pipfile.lock" >> .gitignore
echo "Pipfile" >> .gitignore
# ...
echo "Creazione file .gitignore ... OK"


# # Creo il file .env
# echo "${green}>>> Creazione file .env ... ${reset}"
# echo "DEBUG=True" > .env
# echo "SECRET KEY=ST0C4ZZ0CH3RO77UR4D3C0GL10N1" >> .env
# # ...
# echo "creazione file .env ... OK"



# modify settings.py -----------------
echo "${green}>>> Modifica file settings.py ... ${reset}"
sed -i "s/^from pathlib import Path/from pathlib import Path\nimport os\n\n/g" "${SETTINGS_PY_FILE}"
sed -i "s/^ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = ['*']/g" "${SETTINGS_PY_FILE}"
sed -i "s/\"DIRS\".*/'DIRS': [os.path.join(BASE_DIR, 'templates'),],/g" "${SETTINGS_PY_FILE}"
sed -i "s/^STATIC_URL.*/STATIC_URL = 'static\/'\nSTATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')/g" "${SETTINGS_PY_FILE}"
# to enable use of MEDIA_ROOT and MEDIA_URL
sed -i "s/\"django.contrib.messages.context_processors.messages\",/\"django.contrib.messages.context_processors.messages\",\n                \"django.template.context_processors.media\",/g" "${SETTINGS_PY_FILE}"
# new settings to add to settings.py
cat <<EOF >> "${SETTINGS_PY_FILE}"

# next line will break Django if you're using a direct IP address (e.g., http://192.168.1.230)
#PREPEND_WWW = True

APPEND_SLASH = True

MEDIA_URL = "media/"
MEDIA_ROOT = os.path.join(BASE_DIR, "mediafiles")

STATICFILES_DIRS = ['${ROOT_DIR}/${DJANGO_PROJECT_NAME}/static']

# new in Django 4.1
SECRET_KEY_FALLBACKS = []

EOF



# setup VS Code settings
echo "${green}>>> Configurazione VS Code settings ... ${reset}"
mkdir "${ROOT_DIR}/.vscode"
cat <<EOF >> "${ROOT_DIR}/.vscode/settings.json"

{
    "python.defaultInterpreterPath": "${ROOT_DIR}/${VENV_NAME}/bin/python3",
    "python.terminal.activateEnvironment": true,
    "files.associations": {
        "**/*.html": "html",
        "**/templates/**/*.html": "django-html",
        "**/templates/**/*": "django-txt",
        "**/requirements{/**,*}.{txt,in}": "pip-requirements",
        },
    "[django-html]": {
      "editor.defaultFormatter": "monosans.djlint"
    },
    "[html]": {
      "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[css]": {
      "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "emmet.triggerExpansionOnTab": true,
    "emmet.useInlineCompletions": true,
    "emmet.includeLanguages": {
        "django-html": "html"
    },

    "djlint.useVenv": true
}

EOF


# setup VS Code extensions
echo "${green}>>> Configurazione Code extensions ... ${reset}"
cat <<EOF >> "${ROOT_DIR}/.vscode/extensions.json"

{
    "recommendations": [
        "batisteo.vscode-django",
        "esbenp.prettier-vscode",
        "monosans.djlint",
        "ms-python.python",
        "ms-python.vscode-pylance"
    ]
}

EOF



# a minimal favicon.ico (a placeholder to avoid web server complaints)
favicon_ico="AAABAAEAEBAQAAAAAAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAgAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAEhEQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP7/AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA"
echo ${favicon_ico} | base64 -d > "${ROOT_DIR}/${DJANGO_PROJECT_NAME}/static/favicon.ico"

# a minimal apple-touch-icon.png (a placeholder to avoid web server complaints)
apple_touch_icon_png="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsIAAA7CARUoSoAAAAAgSURBVDhPY/wPBAwUACYoTTYYNWDUABAYNWDgDWBgAABrygQclUTopgAAAABJRU5ErkJggg=="
echo ${apple_touch_icon_png} | base64 -d > "${ROOT_DIR}/${DJANGO_PROJECT_NAME}/static/apple-touch-icon.png"

# a minimal favicon.svg (a placeholder to avoid web server complaints)
favicon_svg="PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+CjxzdmcKICAgd2lkdGg9IjE2bW0iCiAgIGhlaWdodD0iMTZtbSIKICAgdmlld0JveD0iMCAwIDE2IDE2IgogICB2ZXJzaW9uPSIxLjEiCiAgIGlkPSJzdmc1IgogICB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciCiAgIHhtbG5zOnN2Zz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxkZWZzIGlkPSJkZWZzMiIgLz4KICA8ZyBpZD0ibGF5ZXIxIiAvPgo8L3N2Zz4K"
echo ${favicon_svg} | base64 -d > "${ROOT_DIR}/${DJANGO_PROJECT_NAME}/static/favicon.svg"

# normalize.css v8.0.1 | MIT License | github.com/necolas/normalize.css
normalize_css="LyohIG5vcm1hbGl6ZS5jc3MgdjguMC4xIHwgTUlUIExpY2Vuc2UgfCBnaXRodWIuY29tL25lY29sYXMvbm9ybWFsaXplLmNzcyAqLw0KDQovKiBEb2N1bWVudA0KICAgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0gKi8NCg0KLyoqDQogKiAxLiBDb3JyZWN0IHRoZSBsaW5lIGhlaWdodCBpbiBhbGwgYnJvd3NlcnMuDQogKiAyLiBQcmV2ZW50IGFkanVzdG1lbnRzIG9mIGZvbnQgc2l6ZSBhZnRlciBvcmllbnRhdGlvbiBjaGFuZ2VzIGluIGlPUy4NCiAqLw0KDQpodG1sIHsNCiAgbGluZS1oZWlnaHQ6IDEuMTU7IC8qIDEgKi8NCiAgLXdlYmtpdC10ZXh0LXNpemUtYWRqdXN0OiAxMDAlOyAvKiAyICovDQp9DQoNCi8qIFNlY3Rpb25zDQogICA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PSAqLw0KDQovKioNCiAqIFJlbW92ZSB0aGUgbWFyZ2luIGluIGFsbCBicm93c2Vycy4NCiAqLw0KDQpib2R5IHsNCiAgbWFyZ2luOiAwOw0KfQ0KDQovKioNCiAqIFJlbmRlciB0aGUgYG1haW5gIGVsZW1lbnQgY29uc2lzdGVudGx5IGluIElFLg0KICovDQoNCm1haW4gew0KICBkaXNwbGF5OiBibG9jazsNCn0NCg0KLyoqDQogKiBDb3JyZWN0IHRoZSBmb250IHNpemUgYW5kIG1hcmdpbiBvbiBgaDFgIGVsZW1lbnRzIHdpdGhpbiBgc2VjdGlvbmAgYW5kDQogKiBgYXJ0aWNsZWAgY29udGV4dHMgaW4gQ2hyb21lLCBGaXJlZm94LCBhbmQgU2FmYXJpLg0KICovDQoNCmgxIHsNCiAgZm9udC1zaXplOiAyZW07DQogIG1hcmdpbjogMC42N2VtIDA7DQp9DQoNCi8qIEdyb3VwaW5nIGNvbnRlbnQNCiAgID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09ICovDQoNCi8qKg0KICogMS4gQWRkIHRoZSBjb3JyZWN0IGJveCBzaXppbmcgaW4gRmlyZWZveC4NCiAqIDIuIFNob3cgdGhlIG92ZXJmbG93IGluIEVkZ2UgYW5kIElFLg0KICovDQoNCmhyIHsNCiAgYm94LXNpemluZzogY29udGVudC1ib3g7IC8qIDEgKi8NCiAgaGVpZ2h0OiAwOyAvKiAxICovDQogIG92ZXJmbG93OiB2aXNpYmxlOyAvKiAyICovDQp9DQoNCi8qKg0KICogMS4gQ29ycmVjdCB0aGUgaW5oZXJpdGFuY2UgYW5kIHNjYWxpbmcgb2YgZm9udCBzaXplIGluIGFsbCBicm93c2Vycy4NCiAqIDIuIENvcnJlY3QgdGhlIG9kZCBgZW1gIGZvbnQgc2l6aW5nIGluIGFsbCBicm93c2Vycy4NCiAqLw0KDQpwcmUgew0KICBmb250LWZhbWlseTogbW9ub3NwYWNlLCBtb25vc3BhY2U7IC8qIDEgKi8NCiAgZm9udC1zaXplOiAxZW07IC8qIDIgKi8NCn0NCg0KLyogVGV4dC1sZXZlbCBzZW1hbnRpY3MNCiAgID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09ICovDQoNCi8qKg0KICogUmVtb3ZlIHRoZSBncmF5IGJhY2tncm91bmQgb24gYWN0aXZlIGxpbmtzIGluIElFIDEwLg0KICovDQoNCmEgew0KICBiYWNrZ3JvdW5kLWNvbG9yOiB0cmFuc3BhcmVudDsNCn0NCg0KLyoqDQogKiAxLiBSZW1vdmUgdGhlIGJvdHRvbSBib3JkZXIgaW4gQ2hyb21lIDU3LQ0KICogMi4gQWRkIHRoZSBjb3JyZWN0IHRleHQgZGVjb3JhdGlvbiBpbiBDaHJvbWUsIEVkZ2UsIElFLCBPcGVyYSwgYW5kIFNhZmFyaS4NCiAqLw0KDQphYmJyW3RpdGxlXSB7DQogIGJvcmRlci1ib3R0b206IG5vbmU7IC8qIDEgKi8NCiAgdGV4dC1kZWNvcmF0aW9uOiB1bmRlcmxpbmU7IC8qIDIgKi8NCiAgdGV4dC1kZWNvcmF0aW9uOiB1bmRlcmxpbmUgZG90dGVkOyAvKiAyICovDQp9DQoNCi8qKg0KICogQWRkIHRoZSBjb3JyZWN0IGZvbnQgd2VpZ2h0IGluIENocm9tZSwgRWRnZSwgYW5kIFNhZmFyaS4NCiAqLw0KDQpiLA0Kc3Ryb25nIHsNCiAgZm9udC13ZWlnaHQ6IGJvbGRlcjsNCn0NCg0KLyoqDQogKiAxLiBDb3JyZWN0IHRoZSBpbmhlcml0YW5jZSBhbmQgc2NhbGluZyBvZiBmb250IHNpemUgaW4gYWxsIGJyb3dzZXJzLg0KICogMi4gQ29ycmVjdCB0aGUgb2RkIGBlbWAgZm9udCBzaXppbmcgaW4gYWxsIGJyb3dzZXJzLg0KICovDQoNCmNvZGUsDQprYmQsDQpzYW1wIHsNCiAgZm9udC1mYW1pbHk6IG1vbm9zcGFjZSwgbW9ub3NwYWNlOyAvKiAxICovDQogIGZvbnQtc2l6ZTogMWVtOyAvKiAyICovDQp9DQoNCi8qKg0KICogQWRkIHRoZSBjb3JyZWN0IGZvbnQgc2l6ZSBpbiBhbGwgYnJvd3NlcnMuDQogKi8NCg0Kc21hbGwgew0KICBmb250LXNpemU6IDgwJTsNCn0NCg0KLyoqDQogKiBQcmV2ZW50IGBzdWJgIGFuZCBgc3VwYCBlbGVtZW50cyBmcm9tIGFmZmVjdGluZyB0aGUgbGluZSBoZWlnaHQgaW4NCiAqIGFsbCBicm93c2Vycy4NCiAqLw0KDQpzdWIsDQpzdXAgew0KICBmb250LXNpemU6IDc1JTsNCiAgbGluZS1oZWlnaHQ6IDA7DQogIHBvc2l0aW9uOiByZWxhdGl2ZTsNCiAgdmVydGljYWwtYWxpZ246IGJhc2VsaW5lOw0KfQ0KDQpzdWIgew0KICBib3R0b206IC0wLjI1ZW07DQp9DQoNCnN1cCB7DQogIHRvcDogLTAuNWVtOw0KfQ0KDQovKiBFbWJlZGRlZCBjb250ZW50DQogICA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PSAqLw0KDQovKioNCiAqIFJlbW92ZSB0aGUgYm9yZGVyIG9uIGltYWdlcyBpbnNpZGUgbGlua3MgaW4gSUUgMTAuDQogKi8NCg0KaW1nIHsNCiAgYm9yZGVyLXN0eWxlOiBub25lOw0KfQ0KDQovKiBGb3Jtcw0KICAgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0gKi8NCg0KLyoqDQogKiAxLiBDaGFuZ2UgdGhlIGZvbnQgc3R5bGVzIGluIGFsbCBicm93c2Vycy4NCiAqIDIuIFJlbW92ZSB0aGUgbWFyZ2luIGluIEZpcmVmb3ggYW5kIFNhZmFyaS4NCiAqLw0KDQpidXR0b24sDQppbnB1dCwNCm9wdGdyb3VwLA0Kc2VsZWN0LA0KdGV4dGFyZWEgew0KICBmb250LWZhbWlseTogaW5oZXJpdDsgLyogMSAqLw0KICBmb250LXNpemU6IDEwMCU7IC8qIDEgKi8NCiAgbGluZS1oZWlnaHQ6IDEuMTU7IC8qIDEgKi8NCiAgbWFyZ2luOiAwOyAvKiAyICovDQp9DQoNCi8qKg0KICogU2hvdyB0aGUgb3ZlcmZsb3cgaW4gSUUuDQogKiAxLiBTaG93IHRoZSBvdmVyZmxvdyBpbiBFZGdlLg0KICovDQoNCmJ1dHRvbiwNCmlucHV0IHsgLyogMSAqLw0KICBvdmVyZmxvdzogdmlzaWJsZTsNCn0NCg0KLyoqDQogKiBSZW1vdmUgdGhlIGluaGVyaXRhbmNlIG9mIHRleHQgdHJhbnNmb3JtIGluIEVkZ2UsIEZpcmVmb3gsIGFuZCBJRS4NCiAqIDEuIFJlbW92ZSB0aGUgaW5oZXJpdGFuY2Ugb2YgdGV4dCB0cmFuc2Zvcm0gaW4gRmlyZWZveC4NCiAqLw0KDQpidXR0b24sDQpzZWxlY3QgeyAvKiAxICovDQogIHRleHQtdHJhbnNmb3JtOiBub25lOw0KfQ0KDQovKioNCiAqIENvcnJlY3QgdGhlIGluYWJpbGl0eSB0byBzdHlsZSBjbGlja2FibGUgdHlwZXMgaW4gaU9TIGFuZCBTYWZhcmkuDQogKi8NCg0KYnV0dG9uLA0KW3R5cGU9ImJ1dHRvbiJdLA0KW3R5cGU9InJlc2V0Il0sDQpbdHlwZT0ic3VibWl0Il0gew0KICAtd2Via2l0LWFwcGVhcmFuY2U6IGJ1dHRvbjsNCn0NCg0KLyoqDQogKiBSZW1vdmUgdGhlIGlubmVyIGJvcmRlciBhbmQgcGFkZGluZyBpbiBGaXJlZm94Lg0KICovDQoNCmJ1dHRvbjo6LW1vei1mb2N1cy1pbm5lciwNClt0eXBlPSJidXR0b24iXTo6LW1vei1mb2N1cy1pbm5lciwNClt0eXBlPSJyZXNldCJdOjotbW96LWZvY3VzLWlubmVyLA0KW3R5cGU9InN1Ym1pdCJdOjotbW96LWZvY3VzLWlubmVyIHsNCiAgYm9yZGVyLXN0eWxlOiBub25lOw0KICBwYWRkaW5nOiAwOw0KfQ0KDQovKioNCiAqIFJlc3RvcmUgdGhlIGZvY3VzIHN0eWxlcyB1bnNldCBieSB0aGUgcHJldmlvdXMgcnVsZS4NCiAqLw0KDQpidXR0b246LW1vei1mb2N1c3JpbmcsDQpbdHlwZT0iYnV0dG9uIl06LW1vei1mb2N1c3JpbmcsDQpbdHlwZT0icmVzZXQiXTotbW96LWZvY3VzcmluZywNClt0eXBlPSJzdWJtaXQiXTotbW96LWZvY3VzcmluZyB7DQogIG91dGxpbmU6IDFweCBkb3R0ZWQgQnV0dG9uVGV4dDsNCn0NCg0KLyoqDQogKiBDb3JyZWN0IHRoZSBwYWRkaW5nIGluIEZpcmVmb3guDQogKi8NCg0KZmllbGRzZXQgew0KICBwYWRkaW5nOiAwLjM1ZW0gMC43NWVtIDAuNjI1ZW07DQp9DQoNCi8qKg0KICogMS4gQ29ycmVjdCB0aGUgdGV4dCB3cmFwcGluZyBpbiBFZGdlIGFuZCBJRS4NCiAqIDIuIENvcnJlY3QgdGhlIGNvbG9yIGluaGVyaXRhbmNlIGZyb20gYGZpZWxkc2V0YCBlbGVtZW50cyBpbiBJRS4NCiAqIDMuIFJlbW92ZSB0aGUgcGFkZGluZyBzbyBkZXZlbG9wZXJzIGFyZSBub3QgY2F1Z2h0IG91dCB3aGVuIHRoZXkgemVybyBvdXQNCiAqICAgIGBmaWVsZHNldGAgZWxlbWVudHMgaW4gYWxsIGJyb3dzZXJzLg0KICovDQoNCmxlZ2VuZCB7DQogIGJveC1zaXppbmc6IGJvcmRlci1ib3g7IC8qIDEgKi8NCiAgY29sb3I6IGluaGVyaXQ7IC8qIDIgKi8NCiAgZGlzcGxheTogdGFibGU7IC8qIDEgKi8NCiAgbWF4LXdpZHRoOiAxMDAlOyAvKiAxICovDQogIHBhZGRpbmc6IDA7IC8qIDMgKi8NCiAgd2hpdGUtc3BhY2U6IG5vcm1hbDsgLyogMSAqLw0KfQ0KDQovKioNCiAqIEFkZCB0aGUgY29ycmVjdCB2ZXJ0aWNhbCBhbGlnbm1lbnQgaW4gQ2hyb21lLCBGaXJlZm94LCBhbmQgT3BlcmEuDQogKi8NCg0KcHJvZ3Jlc3Mgew0KICB2ZXJ0aWNhbC1hbGlnbjogYmFzZWxpbmU7DQp9DQoNCi8qKg0KICogUmVtb3ZlIHRoZSBkZWZhdWx0IHZlcnRpY2FsIHNjcm9sbGJhciBpbiBJRSAxMCsuDQogKi8NCg0KdGV4dGFyZWEgew0KICBvdmVyZmxvdzogYXV0bzsNCn0NCg0KLyoqDQogKiAxLiBBZGQgdGhlIGNvcnJlY3QgYm94IHNpemluZyBpbiBJRSAxMC4NCiAqIDIuIFJlbW92ZSB0aGUgcGFkZGluZyBpbiBJRSAxMC4NCiAqLw0KDQpbdHlwZT0iY2hlY2tib3giXSwNClt0eXBlPSJyYWRpbyJdIHsNCiAgYm94LXNpemluZzogYm9yZGVyLWJveDsgLyogMSAqLw0KICBwYWRkaW5nOiAwOyAvKiAyICovDQp9DQoNCi8qKg0KICogQ29ycmVjdCB0aGUgY3Vyc29yIHN0eWxlIG9mIGluY3JlbWVudCBhbmQgZGVjcmVtZW50IGJ1dHRvbnMgaW4gQ2hyb21lLg0KICovDQoNClt0eXBlPSJudW1iZXIiXTo6LXdlYmtpdC1pbm5lci1zcGluLWJ1dHRvbiwNClt0eXBlPSJudW1iZXIiXTo6LXdlYmtpdC1vdXRlci1zcGluLWJ1dHRvbiB7DQogIGhlaWdodDogYXV0bzsNCn0NCg0KLyoqDQogKiAxLiBDb3JyZWN0IHRoZSBvZGQgYXBwZWFyYW5jZSBpbiBDaHJvbWUgYW5kIFNhZmFyaS4NCiAqIDIuIENvcnJlY3QgdGhlIG91dGxpbmUgc3R5bGUgaW4gU2FmYXJpLg0KICovDQoNClt0eXBlPSJzZWFyY2giXSB7DQogIC13ZWJraXQtYXBwZWFyYW5jZTogdGV4dGZpZWxkOyAvKiAxICovDQogIG91dGxpbmUtb2Zmc2V0OiAtMnB4OyAvKiAyICovDQp9DQoNCi8qKg0KICogUmVtb3ZlIHRoZSBpbm5lciBwYWRkaW5nIGluIENocm9tZSBhbmQgU2FmYXJpIG9uIG1hY09TLg0KICovDQoNClt0eXBlPSJzZWFyY2giXTo6LXdlYmtpdC1zZWFyY2gtZGVjb3JhdGlvbiB7DQogIC13ZWJraXQtYXBwZWFyYW5jZTogbm9uZTsNCn0NCg0KLyoqDQogKiAxLiBDb3JyZWN0IHRoZSBpbmFiaWxpdHkgdG8gc3R5bGUgY2xpY2thYmxlIHR5cGVzIGluIGlPUyBhbmQgU2FmYXJpLg0KICogMi4gQ2hhbmdlIGZvbnQgcHJvcGVydGllcyB0byBgaW5oZXJpdGAgaW4gU2FmYXJpLg0KICovDQoNCjo6LXdlYmtpdC1maWxlLXVwbG9hZC1idXR0b24gew0KICAtd2Via2l0LWFwcGVhcmFuY2U6IGJ1dHRvbjsgLyogMSAqLw0KICBmb250OiBpbmhlcml0OyAvKiAyICovDQp9DQoNCi8qIEludGVyYWN0aXZlDQogICA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PSAqLw0KDQovKg0KICogQWRkIHRoZSBjb3JyZWN0IGRpc3BsYXkgaW4gRWRnZSwgSUUgMTArLCBhbmQgRmlyZWZveC4NCiAqLw0KDQpkZXRhaWxzIHsNCiAgZGlzcGxheTogYmxvY2s7DQp9DQoNCi8qDQogKiBBZGQgdGhlIGNvcnJlY3QgZGlzcGxheSBpbiBhbGwgYnJvd3NlcnMuDQogKi8NCg0Kc3VtbWFyeSB7DQogIGRpc3BsYXk6IGxpc3QtaXRlbTsNCn0NCg0KLyogTWlzYw0KICAgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0gKi8NCg0KLyoqDQogKiBBZGQgdGhlIGNvcnJlY3QgZGlzcGxheSBpbiBJRSAxMCsuDQogKi8NCg0KdGVtcGxhdGUgew0KICBkaXNwbGF5OiBub25lOw0KfQ0KDQovKioNCiAqIEFkZCB0aGUgY29ycmVjdCBkaXNwbGF5IGluIElFIDEwLg0KICovDQoNCltoaWRkZW5dIHsNCiAgZGlzcGxheTogbm9uZTsNCn0NCg=="
echo ${normalize_css} | base64 -d > "${ROOT_DIR}/${DJANGO_PROJECT_NAME}/static/normalize.css"

# following HTML5 boilerplate is from https://www.sitepoint.com/a-basic-html5-template/
cat <<EOF > "${ROOT_DIR}/${DJANGO_PROJECT_NAME}/templates/base.html"
{% load static %}

<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>{% block title_tag %}Title Tag{% endblock title_tag %}</title>

<meta name="description" content="">
<meta name="author" content="">

<meta property="og:title" content="">
<meta property="og:type" content="website">
<meta property="og:url" content="">
<meta property="og:description" content="">
<meta property="og:image" content="">

<link rel="icon" href="{% static "favicon.ico" %}" />
<link rel="icon" href="{% static "favicon.svg" %}" type="image/svg+xml" />
<link rel="apple-touch-icon" href="{% static "apple-touch-icon.png" %}" />
<link rel="stylesheet" href="{% static "normalize.css" %}" />
<link rel="stylesheet" href="{% static "styles.css" %}" />
</head>

<body>
{% block body_content %}
{% endblock body_content %}
</body>
</html>

EOF

# Collect static files
echo "${green}>>> Collecting static files ... ${reset}"
echo "${red}>>> ${TEMPLATE_NAME} - ${PWD} ${reset}"
cd ${TEMPLATE_NAME} || die "Errore: cartella ${TEMPLATE_NAME} non esiste"
pipenv run ./manage.py collectstatic # --noinput

echo "${green}>>> Collecting static files ... ${reset}"
pipenv run ./manage.py makemigrations

echo "${green}>>> Collecting static files ... ${reset}"
pipenv run ./manage.py migrate

echo "${green}>>> Collecting static files ... ${reset}"
pipenv run ./manage.py createsuperuser

# setup git
echo "${green}>>> Configurazione Git ... ${reset}"
git init
git add .
git commit -m "Initial commit"

echo "${green}>>> ${DJANGO_PROJECT_NAME} è pronto! ${reset}"

pipenv run ./manage.py runserver

