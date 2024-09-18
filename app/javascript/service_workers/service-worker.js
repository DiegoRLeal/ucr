const OFFLINE_VERSION = 1;
const CACHE_NAME = `offline-v${OFFLINE_VERSION}`;
const OFFLINE_URL = '/offline.html';  // Verifique se este arquivo está acessível
const OFFLINE_IMG = '/assets/icons/apple-icon.png';  // Verifique se este arquivo está acessível

self.addEventListener('install', (event) => {
  console.log('Service Worker instalando...');

  event.waitUntil((async () => {
    const cache = await caches.open(CACHE_NAME);
    try {
      await cache.addAll([OFFLINE_URL, OFFLINE_IMG]);
    } catch (error) {
      console.error('Erro ao adicionar arquivos ao cache:', error);
    }
  })());
});


self.addEventListener('activate', function(event) {
  console.log('Service Worker activated.');
  event.waitUntil((async () => {
    const cacheNames = await caches.keys();
    await Promise.all(
      cacheNames.map((cacheName) => {
        if (cacheName !== CACHE_NAME) {
          console.log('Deletando cache antigo:', cacheName);
          return caches.delete(cacheName);
        }
      })
    );
  })());
});

self.addEventListener('fetch', function(event) {
  console.log('Service Worker interceptando fetch para:', event.request.url);

  event.respondWith((async () => {
    try {
      const preloadResponse = await event.preloadResponse;
      if (preloadResponse) {
        return preloadResponse;
      }

      const cachedResponse = await caches.match(event.request);
      if (cachedResponse) {
        return cachedResponse;
      }

      return await fetch(event.request);
    } catch (error) {
      console.error('Fetch falhou; retornando página offline:', error);

      const cache = await caches.open(CACHE_NAME);
      const cachedOfflineResponse = await cache.match(OFFLINE_URL);

      if (cachedOfflineResponse) {
        return cachedOfflineResponse;
      }

      return new Response('Você está offline, e a página não está disponível no cache.', {
        status: 503,
        headers: { 'Content-Type': 'text/html' }
      });
    }
  })());
});
