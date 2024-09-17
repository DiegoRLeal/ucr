// External imports
import "bootstrap";
// Internal imports
import askPushNotifications from '../plugins/push_notifications';

window.addEventListener('load', () => {
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register('/service_workers/service-worker.js').then(registration => {
      console.log('ServiceWorker registered: ', registration);

      let serviceWorker;
      if (registration.installing) {
        serviceWorker = registration.installing;
        console.log('Service worker installing.');
      } else if (registration.waiting) {
        serviceWorker = registration.waiting;
        console.log('Service worker installed & waiting.');
      } else if (registration.active) {
        serviceWorker = registration.active;
        console.log('Service worker active.');
      }

      // Solicitação de permissão para notificações
      window.Notification.requestPermission().then(permission => {
        if (permission !== 'granted') {
          throw new Error('Permission not granted for Notification');
        }
      });
    }).catch(registrationError => {
      console.log('Service worker registration failed: ', registrationError);
    });
  }
});

// Forçar recarregamento quando a conexão estiver offline
window.addEventListener('offline', () => {
  alert('Você está offline. Carregando conteúdo em cache...');
  window.location.reload();
});

// Integração com Turbolinks para carregar as notificações push
document.addEventListener('turbolinks:load', () => {
  askPushNotifications();
});
