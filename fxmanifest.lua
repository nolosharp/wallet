fx_version 'cerulean'
games { 'rdr3' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
ui_page 'ui/index.html'

author 'Emolitt'
description 'money but storable'
version '1.0.0'

-- Définir les fichiers côté client
client_scripts {
    'client.lua'
}

-- Définir les fichiers côté serveur
server_scripts {
    'server.lua'
}

shared_scripts {
    'config.lua'
}