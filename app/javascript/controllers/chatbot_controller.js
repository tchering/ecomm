import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "messages", "input"];

  connect() {
    this.initializeChatbot();
  }

  initializeChatbot() {
    this.addMessage("Hello! How can I help you today?", "bot");
  }

  toggle() {
    this.containerTarget.classList.toggle("hidden");
    if (!this.containerTarget.classList.contains("hidden")) {
      this.inputTarget.focus();
    }
  }

  async sendMessage(event) {
    event.preventDefault();
    const message = this.inputTarget.value.trim();

    if (message.length === 0) return;

    // Add user message to chat
    this.addMessage(message, "user");

    // Clear input
    this.inputTarget.value = "";

    try {
      // Send message to server
      const response = await fetch("/api/chatbot/message", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
        body: JSON.stringify({ message }),
      });

      const data = await response.json();

      // Add bot response to chat
      this.addMessage(data.message, "bot");
    } catch (error) {
      console.error("Error sending message:", error);
      this.addMessage(
        "Sorry, I'm having trouble responding right now. Please try again later.",
        "bot"
      );
    }
  }

  addMessage(message, sender) {
    const messageDiv = document.createElement("div");
    messageDiv.className = `message ${sender} mb-4 ${
      sender === "bot"
        ? "flex items-start"
        : "flex items-start flex-row-reverse"
    }`;

    const avatar = document.createElement("div");
    avatar.className =
      "flex-shrink-0 h-8 w-8 rounded-full bg-gray-200 flex items-center justify-center";
    avatar.innerHTML =
      sender === "bot"
        ? '<i class="fas fa-robot text-gray-500"></i>'
        : '<i class="fas fa-user text-gray-500"></i>';

    const bubble = document.createElement("div");
    bubble.className = `mx-3 px-4 py-2 rounded-lg ${
      sender === "bot" ? "bg-gray-100 text-gray-800" : "bg-blue-600 text-white"
    }`;
    bubble.textContent = message;

    messageDiv.appendChild(avatar);
    messageDiv.appendChild(bubble);

    this.messagesTarget.appendChild(messageDiv);
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
  }
}
