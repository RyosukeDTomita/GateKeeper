import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('http://localhost/form');

  await page.getByPlaceholder('user_id').click();
  await page.waitForTimeout(1000);
  await page.getByPlaceholder('user_id').fill('user');
  await page.getByPlaceholder('password').click();
  await page.waitForTimeout(1000);
  await page.getByPlaceholder('password').fill('password');

  await page.waitForTimeout(2000);
  await page.getByRole('button', { name: 'Login' }).click();

  await page.waitForTimeout(5000);
  const content = await page.textContent('body');
  expect(content).toContain('Access Denied');
});
