import {defineConfig} from '@playwright/test';
export default defineConfig({testDir:'./tests/browser',timeout:30000,use:{baseURL:'http://127.0.0.1:4178',headless:true,launchOptions:process.env.SIDEBAND_BROWSER?{executablePath:process.env.SIDEBAND_BROWSER}:{}},webServer:{command:'npm start',url:'http://127.0.0.1:4178',reuseExistingServer:!process.env.CI},reporter:'list'});
