import { create } from 'zustand';
import SockJS from 'sockjs-client';
import Stomp from 'stompjs';

interface UnreadNotification {
  senderId: number;
  senderName: string;
  count: number;
  lastMessage: string;
}

interface ChatNotificationState {
  unreadCounts: Record<number, number>;
  notifications: UnreadNotification[];
  totalUnread: number;
  
  fetchUnreadStatus: () => Promise<void>;
  addNotification: (senderId: number, senderName: string, message: string) => void;
  markAsRead: (senderId: number) => Promise<void>;
  
  
  initializeWebSocket: (userId: number, token: string) => void;
  disconnect: () => void;
}

export const useChatNotificationStore = create<ChatNotificationState>((set, get) => {
  let stompClient: Stomp.Client | null = null;

  return {
    unreadCounts: {},
    notifications: [],
    totalUnread: 0,

    fetchUnreadStatus: async () => {
      console.log("[NotificationStore] Fetching unread notifications for Admin...");
      try {
        const response = await fetch('http://localhost:8123/api/chat/unread-notifications', {
          headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
        });
        if (response.ok) {
          const notifications = await response.json();
          console.log("[NotificationStore] Admin unread notifications fetched:", notifications);
          const counts: Record<number, number> = {};
          let total = 0;
          notifications.forEach((n: UnreadNotification) => {
            counts[n.senderId] = n.count;
            total += n.count;
          });
          set({ unreadCounts: counts, totalUnread: total, notifications });
        }
      } catch (err) {
        console.error('Failed to fetch unread status', err);
      }
    },

    addNotification: (senderId, senderName, message) => {
      set(state => {
        const newCounts = { ...state.unreadCounts, [senderId]: (state.unreadCounts[senderId] || 0) + 1 };
        const total = Object.values(newCounts).reduce((a, b) => a + b, 0);
        
        
        const existingIdx = state.notifications.findIndex(n => n.senderId === senderId);
        let newNotifications = [...state.notifications];
        if (existingIdx > -1) {
          newNotifications[existingIdx] = {
            ...newNotifications[existingIdx],
            count: newCounts[senderId],
            lastMessage: message
          };
        } else {
          newNotifications.unshift({ senderId, senderName, count: 1, lastMessage: message });
        }

        return { unreadCounts: newCounts, totalUnread: total, notifications: newNotifications };
      });
    },

    markAsRead: async (senderId) => {
      try {
        await fetch(`http://localhost:8123/api/chat/mark-read/${senderId}`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${localStorage.getItem('admin_token')}` }
        });
        
        set(state => {
          const newCounts = { ...state.unreadCounts };
          delete newCounts[senderId];
          const total = Object.values(newCounts).reduce((a: any, b: any) => a + (b as number), 0) as number;
          const newNotifications = state.notifications.filter(n => n.senderId !== senderId);
          return { unreadCounts: newCounts, totalUnread: total, notifications: newNotifications };
        });
      } catch (err) {
        console.error('Failed to mark as read', err);
      }
    },

    initializeWebSocket: (userId, token) => {
      console.log("[NotificationStore] Initializing WebSocket (Admin) for user:", userId);
      if (stompClient?.connected) {
        console.log("[NotificationStore] Admin WebSocket already connected");
        return;
      }

      const socket = new SockJS('http://localhost:8123/ws-chat');
      stompClient = Stomp.over(socket);
      stompClient.debug = (str) => {
        if (str.includes("CONNECTED") || str.includes("ERROR")) {
            console.log("[NotificationStore] Admin STOMP Debug:", str);
        }
      };

      stompClient.connect({ 'Authorization': 'Bearer ' + token }, () => {
        console.log("[NotificationStore] Admin STOMP Connected as user:", userId);
        stompClient?.subscribe(`/topic/chat/${userId}`, (message) => {
          const data = JSON.parse(message.body);
          console.log("[NotificationStore] Admin notification received:", data);
          if (data.senderId !== userId) {
            get().addNotification(data.senderId, data.senderName || 'Staff', data.content);
          }
        });
      }, (error) => {
        console.error("[NotificationStore] Admin STOMP Error:", error);
      });
    },

    disconnect: () => {
      if (stompClient?.connected) {
        stompClient.disconnect(() => {
          stompClient = null;
        });
      }
    }
  };
});
