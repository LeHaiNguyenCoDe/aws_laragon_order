// 🚀 Application E2E Tests
const { test, expect } = require('@playwright/test');

test.describe('🚀 Laravel Application Tests', () => {
  
  test('should load homepage successfully', async ({ page }) => {
    // 🏠 Navigate to homepage
    await page.goto('/');
    
    // ✅ Verify page loads
    await expect(page).toHaveTitle(/Laravel/);
    
    // 🔍 Check for Laravel branding
    const content = await page.textContent('body');
    expect(content).toContain('Laravel');
  });

  test('should handle 404 pages gracefully', async ({ page }) => {
    // 🔍 Navigate to non-existent page
    const response = await page.goto('/non-existent-page');
    
    // ❌ Verify 404 status
    expect(response.status()).toBe(404);
    
    // 🎨 Verify custom 404 page (if exists)
    const content = await page.textContent('body');
    expect(content.toLowerCase()).toContain('not found');
  });

  test('should have proper meta tags', async ({ page }) => {
    await page.goto('/');
    
    // 🏷️ Check meta viewport
    const viewport = await page.getAttribute('meta[name="viewport"]', 'content');
    expect(viewport).toContain('width=device-width');
    
    // 🔒 Check CSRF token
    const csrfToken = await page.getAttribute('meta[name="csrf-token"]', 'content');
    expect(csrfToken).toBeTruthy();
  });

  test('should load CSS and JS assets', async ({ page }) => {
    // 📊 Monitor network requests
    const cssRequests = [];
    const jsRequests = [];
    
    page.on('response', response => {
      const url = response.url();
      if (url.includes('.css')) cssRequests.push(response);
      if (url.includes('.js')) jsRequests.push(response);
    });
    
    await page.goto('/');
    
    // ⏳ Wait for assets to load
    await page.waitForLoadState('networkidle');
    
    // ✅ Verify assets loaded successfully
    cssRequests.forEach(response => {
      expect(response.status()).toBe(200);
    });
    
    jsRequests.forEach(response => {
      expect(response.status()).toBe(200);
    });
  });

  test('should be responsive on mobile devices', async ({ page }) => {
    // 📱 Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    
    // 🔍 Check mobile layout
    const body = await page.locator('body');
    await expect(body).toBeVisible();
    
    // ✅ Verify no horizontal scroll
    const scrollWidth = await page.evaluate(() => document.body.scrollWidth);
    const clientWidth = await page.evaluate(() => document.body.clientWidth);
    expect(scrollWidth).toBeLessThanOrEqual(clientWidth + 1); // Allow 1px tolerance
  });

  test('should handle form submissions', async ({ page }) => {
    await page.goto('/');
    
    // 🔍 Look for forms
    const forms = await page.locator('form').count();
    
    if (forms > 0) {
      // 📝 Test first form if exists
      const firstForm = page.locator('form').first();
      
      // 🔒 Verify CSRF protection
      const csrfInput = firstForm.locator('input[name="_token"]');
      if (await csrfInput.count() > 0) {
        const csrfValue = await csrfInput.getAttribute('value');
        expect(csrfValue).toBeTruthy();
      }
    }
  });

  test('should have proper security headers', async ({ page }) => {
    const response = await page.goto('/');
    const headers = response.headers();
    
    // 🔒 Check security headers
    expect(headers).toHaveProperty('x-frame-options');
    expect(headers).toHaveProperty('x-content-type-options');
    
    // 🛡️ Check for XSS protection
    if (headers['x-xss-protection']) {
      expect(headers['x-xss-protection']).toBe('1; mode=block');
    }
  });

  test('should handle API endpoints', async ({ page }) => {
    // 🔍 Test API health endpoint
    const apiResponse = await page.request.get('/api/health');
    expect(apiResponse.status()).toBe(200);
    
    const apiData = await apiResponse.json();
    expect(apiData).toHaveProperty('status');
  });

  test('should maintain session across requests', async ({ page }) => {
    await page.goto('/');
    
    // 🍪 Check for session cookie
    const cookies = await page.context().cookies();
    const sessionCookie = cookies.find(cookie => 
      cookie.name.includes('session') || cookie.name.includes('laravel')
    );
    
    if (sessionCookie) {
      expect(sessionCookie.value).toBeTruthy();
      expect(sessionCookie.httpOnly).toBe(true);
    }
  });

  test('should handle concurrent requests', async ({ page }) => {
    // 🚀 Make multiple concurrent requests
    const promises = Array.from({ length: 5 }, () => 
      page.request.get('/health')
    );
    
    const responses = await Promise.all(promises);
    
    // ✅ All requests should succeed
    responses.forEach(response => {
      expect(response.status()).toBe(200);
    });
  });

});
