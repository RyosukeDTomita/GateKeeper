import { test, expect } from '@playwright/test';

test('test', async ({ page }) => {
  await page.goto('http://localhost/');
  await page.goto('http://user:password@localhost/basic');
  const content = await page.textContent('body');
  expect(content).toContain('Example Domain');
});
