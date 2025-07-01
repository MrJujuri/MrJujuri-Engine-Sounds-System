Config = {}

Config.UsePermissions = true

Config.EngineSounds = {
    car = {
        ['Mazda RX7 13B Whitelist'] = {
            sound = 'aq31maz13btune',
            vehicles = { 'sultan' },
            category = 'JDM',
            whitelist = {
                ['steam:123456789ABC123'] = true,
            }
        },
        ['Mazda RX7 13B Bukan Whitelist'] = {
            sound = 'aq31maz13btune',
            category = 'JDM',
            vehicles = false,
            whitelist = false -- semua donator boleh
        },
        ['Mazda RX7'] = {
            sound = 'aq09mazbpze',
            category = 'JDM',
            vehicles = false,
            whitelist = false -- semua donator boleh
        },
        ['Mazda RX7 13B'] = {
            sound = 'aq31maz13btune',
            category = 'Euro',
            vehicles = false,
            whitelist = false -- semua donator boleh
        }
    },
    bike = {
        ['Ducati V4R'] = {
            sound = 'kc32ducavr4',
            vehicles = { 'r6' },
            category = 'JDM',
            whitelist = {
                ['steam:123456789ABC123'] = true
            }
        },
        ['Ducati V4R All'] = {
            sound = 'kc32ducavr4',
            vehicles = false,
            category = 'JDM',
            whitelist = false -- semua donator boleh
        }
    }
}
