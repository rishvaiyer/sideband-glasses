import {test,expect} from '@playwright/test';
test('desktop session, evidence, familiar control, recap and export',async({page})=>{
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.setViewportSize({width:1440,height:1100});await page.goto('/');
 await expect(page.getByText('Interactive demo · simulated signals')).toBeVisible();
 await page.getByRole('button',{name:'Try a listening session'}).click();
 await expect(page.locator('[data-signal="A"]')).toBeVisible();
 await expect(page.locator('#detail')).toContainText('Recording status');
 await page.getByRole('button',{name:'This is mine'}).click();
 await expect(page.locator('[data-signal="A"]')).toContainText('Familiar');
 await page.getByLabel('Quiet mode').check();
 await page.getByRole('button',{name:'Hear recap'}).click();
 await expect(page.locator('#announcement')).toContainText('Recording was not determined');
 const downloadPromise=page.waitForEvent('download');await page.getByRole('button',{name:'Export session'}).click();const download=await downloadPromise;expect(download.suggestedFilename()).toBe('sideband-demo-session.json');
 await page.screenshot({path:'evidence/desktop.png',fullPage:true});
 await page.getByRole('button',{name:'Pause',exact:true}).click();await expect(page.getByRole('button',{name:'Resume',exact:true})).toBeVisible();
 await page.getByRole('button',{name:'Reset',exact:true}).click();await expect(page.locator('#signals')).toContainText('A moment of quiet.');expect(errors).toEqual([]);
});
test('mobile layout and scenario switching',async({page})=>{
 await page.setViewportSize({width:390,height:844});await page.goto('/');
 await page.getByRole('button',{name:'On the train'}).click();await expect(page.locator('[data-scene="commute"]')).toHaveAttribute('aria-pressed','true');
 await expect(page.locator('[data-signal="A"]')).toBeVisible();
 expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth)).toBe(true);
 await page.screenshot({path:'evidence/mobile.png',fullPage:true});
 await page.getByRole('button',{name:'Back home'}).click();await expect(page.locator('#clock')).toContainText('00:00');
});
test('keyboard can start a session; speech unavailability is honest',async({page})=>{
 await page.addInitScript(()=>Object.defineProperty(window,'speechSynthesis',{value:undefined,configurable:true}));
 await page.goto('/');await page.locator('#audio').click();await expect(page.locator('#audio-status')).toContainText('Speech is unavailable');await page.locator('#start').focus();await page.keyboard.press('Enter');await expect(page.locator('[data-signal="A"]')).toBeVisible();
});
