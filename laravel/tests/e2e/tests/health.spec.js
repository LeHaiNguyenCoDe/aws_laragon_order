// 🏥 Health Check E2E Tests
const { test, expect } = require('@playwright/test');

test.describe('🏥 Application Health Checks', () => {
  
  test('should return healthy status', async ({ page }) => {
    // 🔍 Navigate to health endpoint
    const response = await page.goto('/health');
    
    // ✅ Verify response status
    expect(response.status()).toBe(200);
    
    // 📊 Verify response content
    const content = await page.textContent('body');
    expect(content).toContain('healthy');
  });

  test('should have proper response headers', async ({ page }) => {
    const response = await page.goto('/health');
    
    // 🔍 Check content type
    expect(response.headers()['content-type']).toContain('application/json');
    
    // ⚡ Check response time (should be fast)
    const startTime = Date.now();
    await page.goto('/health');
    const responseTime = Date.now() - startTime;
    expect(responseTime).toBeLessThan(1000); // Less than 1 second
  });

  test('should include system information', async ({ page }) => {
    await page.goto('/health');
    
    const healthData = await page.evaluate(() => {
      return JSON.parse(document.body.textContent);
    });
    
    // 🔍 Verify required health check fields
    expect(healthData).toHaveProperty('status');
    expect(healthData).toHaveProperty('timestamp');
    expect(healthData).toHaveProperty('services');
    
    // ✅ Verify status is healthy
    expect(healthData.status).toBe('healthy');
  });

  test('should check database connectivity', async ({ page }) => {
    await page.goto('/health');
    
    const healthData = await page.evaluate(() => {
      return JSON.parse(document.body.textContent);
    });
    
    // 🗄️ Verify database health
    expect(healthData.services).toHaveProperty('database');
    expect(healthData.services.database.status).toBe('healthy');
  });

  test('should check cache connectivity', async ({ page }) => {
    await page.goto('/health');
    
    const healthData = await page.evaluate(() => {
      return JSON.parse(document.body.textContent);
    });
    
    // 🚀 Verify cache health (if configured)
    if (healthData.services.cache) {
      expect(healthData.services.cache.status).toBe('healthy');
    }
  });

});
