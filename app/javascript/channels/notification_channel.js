import consumer from "./consumer";

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to NotificationChannel");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log("Received data:", data);

    // Handle different types of updates
    if (data.action === "update_count") {
      // Update the unread count in the navbar
      this.updateUnreadCount(data.html);
    } else if (data.action === "replace") {
      // Replace an existing notification (e.g., when marked as read)
      const notificationElement = document.getElementById(data.target);
      if (notificationElement) {
        notificationElement.outerHTML = data.html;
      }
    } else if (data.action === "prepend") {
      // Add a new notification to the list
      this.prependNotification(data.html);
      this.showToast(data.title, data.message);
    } else if (data.html) {
      // Default case for backward compatibility
      this.prependNotification(data.html);
    }
  },

  prependNotification(html) {
    const notificationsList = document.getElementById("notifications-list");
    if (notificationsList) {
      notificationsList.insertAdjacentHTML("afterbegin", html);
    }
  },

  updateUnreadCount(html) {
    const unreadCountContainer = document.getElementById(
      "unread-notifications-count"
    );
    if (unreadCountContainer) {
      unreadCountContainer.innerHTML = html;
    }
  },

  showToast(title, message) {
    // Create toast notification
    const toast = document.createElement("div");
    toast.className =
      "fixed bottom-4 right-4 bg-white shadow-lg rounded-lg p-4 mb-4 z-50 transition-all duration-500 transform translate-y-0";
    toast.innerHTML = `
      <div class="flex items-center">
        <div class="flex-shrink-0">
          <i class="fas fa-bell text-blue-500"></i>
        </div>
        <div class="ml-3">
          <p class="text-sm font-medium text-gray-900">${
            title || "New Notification"
          }</p>
          <p class="text-sm text-gray-500">${
            message || "You have a new notification"
          }</p>
        </div>
      </div>
    `;
    document.body.appendChild(toast);

    // Remove toast after 5 seconds
    setTimeout(() => {
      toast.classList.add("translate-y-full", "opacity-0");
      setTimeout(() => toast.remove(), 500);
    }, 5000);
  },
});
