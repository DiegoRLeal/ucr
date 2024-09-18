const OFFLINE_VERSION = 1;
const CACHE_NAME = `offline-v${OFFLINE_VERSION}`;
const OFFLINE_URL = '/offline.html.erb'; // Verifique o caminho correto
const OFFLINE_IMG = '/apple-icon.png'; // Verifique o caminho correto

self.addEventListener('install', function(event) {
  console.log('Service Worker installing...');

  event.waitUntil((async () => {
    try {
      const cache = await caches.open(CACHE_NAME);
      console.log('Cache aberto durante a instalação:', CACHE_NAME);

      // Verifique se os arquivos realmente estão acessíveis antes de adicionar ao cache
      const filesToCache = [OFFLINE_URL, OFFLINE_IMG];

      await Promise.all(filesToCache.map(async (file) => {
        const response = await fetch(file);
        if (!response || response.status !== 200) {
          throw new Error(`Falha ao buscar o arquivo: ${file}, status: ${response ? response.status : 'sem resposta'}`);
        }
        console.log(`Adicionando ao cache: ${file}`);
        await cache.put(file, response);
      }));

      console.log('Todos os arquivos foram armazenados em cache.');
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
