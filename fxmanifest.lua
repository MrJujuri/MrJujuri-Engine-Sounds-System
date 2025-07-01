fx_version 'cerulean'
game 'gta5'

author 'MrJujuri#8654  <https://github.com/MrJujuri>'
description 'Custom Engine Sound System based on ParadoxEngineSounds by JnKTechstuff'
version '1.0.0'

shared_script 'config.lua'
client_script 'client.lua'
server_script 'server.lua'

dependencies {
    'ox_lib',
    'ox_target'
}