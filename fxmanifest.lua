fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'in_game_clothes_editor'
author 'EnderDevelopment'
description 'In-game clothing variation editor with persistent server-side outfit storage.'
version '1.1.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'
