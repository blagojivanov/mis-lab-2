importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: "AIzaSyDZ8EYZOM330WxW7e5yWut8BkpexKAqYDY",
    authDomain: "mis-lab-3-221037.firebaseapp.com",
    projectId: "mis-lab-3-221037",
    storageBucket: "mis-lab-3-221037.firebasestorage.app",
    messagingSenderId: "223270406672",
    appId: "1:223270406672:web:6fe64ce30e53083930d895",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background Message:', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/firebase-logo.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});