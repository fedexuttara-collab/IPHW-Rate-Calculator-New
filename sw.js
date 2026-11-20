const CACHE_NAME = "fedex-calculator-v1";

self.addEventListener("install", (event) => {
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    (async () => {
      await self.clients.claim();
    })()
  );
});

self.addEventListener("fetch", (event) => {
  // Network requests will continue normally.
  // Supabase and calculator data will remain online.
});
