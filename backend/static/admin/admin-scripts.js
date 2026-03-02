// ====================== ADMIN PORTAL UTILITIES ======================

/**
 * Check if admin is authenticated
 * If not, redirect to login page
 */
function checkAdminAuth() {
    const token = localStorage.getItem('adminToken');
    const admin = localStorage.getItem('admin');

    if (!token || !admin) {
        // Redirect to login if not authenticated
        if (!window.location.href.includes('/admin/login') && !window.location.href.includes('/admin/otp-verify')) {
            window.location.href = '/admin/login';
        }
    }
}

/**
 * Logout admin
 */
function adminLogout() {
    if (confirm('Are you sure you want to logout?')) {
        localStorage.removeItem('adminToken');
        localStorage.removeItem('admin');
        localStorage.removeItem('adminEmail');
        window.location.href = '/admin/login';
    }
}

/**
 * Open modal
 */
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('active');
        document.body.style.overflow = 'hidden';
    }
}

/**
 * Close modal
 */
function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
        document.body.style.overflow = 'auto';
    }
}

/**
 * Format date to readable format
 */
function formatDate(dateObj) {
    if (!dateObj) return 'N/A';
    
    let date;
    if (typeof dateObj === 'object' && dateObj.seconds) {
        // Firebase timestamp
        date = new Date(dateObj.seconds * 1000);
    } else {
        date = new Date(dateObj);
    }

    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}

/**
 * Format time ago (e.g., "2 hours ago")
 */
function timeAgo(dateObj) {
    if (!dateObj) return 'N/A';
    
    let date;
    if (typeof dateObj === 'object' && dateObj.seconds) {
        date = new Date(dateObj.seconds * 1000);
    } else {
        date = new Date(dateObj);
    }

    const seconds = Math.floor((new Date() - date) / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) return days + ' day' + (days > 1 ? 's' : '') + ' ago';
    if (hours > 0) return hours + ' hour' + (hours > 1 ? 's' : '') + ' ago';
    if (minutes > 0) return minutes + ' minute' + (minutes > 1 ? 's' : '') + ' ago';
    return 'Just now';
}

/**
 * Truncate text
 */
function truncateText(text, maxLength = 100) {
    if (text.length > maxLength) {
        return text.substring(0, maxLength) + '...';
    }
    return text;
}

/**
 * Get priority color
 */
function getPriorityColor(priority) {
    const colors = {
        'high': '#ef4444',
        'medium': '#f97316',
        'low': '#3b82f6'
    };
    return colors[priority] || '#6b7280';
}

/**
 * Get status color
 */
function getStatusColor(status) {
    const colors = {
        'pending': '#f59e0b',
        'in_progress': '#3b82f6',
        'resolved': '#10b981',
        'rejected': '#ef4444'
    };
    return colors[status] || '#6b7280';
}

/**
 * Show notification
 */
function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 16px 24px;
        border-radius: 8px;
        color: white;
        font-weight: 500;
        z-index: 2000;
        animation: slideIn 0.3s ease;
    `;

    if (type === 'success') {
        notification.style.backgroundColor = '#10b981';
    } else if (type === 'error') {
        notification.style.backgroundColor = '#ef4444';
    } else if (type === 'warning') {
        notification.style.backgroundColor = '#f59e0b';
    } else {
        notification.style.backgroundColor = '#3b82f6';
    }

    document.body.appendChild(notification);

    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

/**
 * Make API request with authentication
 */
async function adminFetch(url, options = {}) {
    const token = localStorage.getItem('adminToken');
    
    const headers = {
        'Content-Type': 'application/json',
        ...options.headers
    };

    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(url, {
        ...options,
        headers
    });

    if (response.status === 401) {
        // Token expired, logout
        adminLogout();
        return null;
    }

    return response;
}

/**
 * Format complaint status for display
 */
function formatStatus(status) {
    return status
        .replace(/_/g, ' ')
        .split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
}

/**
 * Get complaint statistics
 */
function getComplaintStats(complaints) {
    const stats = {
        total: complaints.length,
        pending: 0,
        in_progress: 0,
        resolved: 0,
        rejected: 0,
        high_priority: 0,
        medium_priority: 0,
        low_priority: 0
    };

    complaints.forEach(complaint => {
        stats[complaint.status] = (stats[complaint.status] || 0) + 1;
        stats[complaint.priority + '_priority'] = (stats[complaint.priority + '_priority'] || 0) + 1;
    });

    return stats;
}

/**
 * Export data as JSON
 */
function exportAsJSON(data, filename = 'data.json') {
    const dataStr = JSON.stringify(data, null, 2);
    const dataBlob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
}

/**
 * Export data as CSV
 */
function exportAsCSV(complaints, filename = 'complaints.csv') {
    const headers = ['ID', 'Title', 'Status', 'Priority', 'Location', 'Reporter', 'Created Date'];
    const rows = complaints.map(c => [
        c.id,
        c.title,
        c.status,
        c.priority,
        c.location_text || c.location?.text || 'N/A',
        c.reporter_name || 'Anonymous',
        formatDate(c.createdAt)
    ]);

    let csv = headers.join(',') + '\n';
    rows.forEach(row => {
        csv += row.map(cell => `"${cell}"`).join(',') + '\n';
    });

    const blob = new Blob([csv], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
}

/**
 * Validate email
 */
function validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

/**
 * Validate OTP format
 */
function validateOTP(otp) {
    return /^[A-Z0-9]{6}$/.test(otp);
}

/**
 * Get initials from name
 */
function getInitials(name) {
    if (!name) return 'AD';
    return name
        .split(' ')
        .map(n => n[0])
        .join('')
        .toUpperCase()
        .substring(0, 2);
}

/**
 * Convert Firebase Timestamp to Date
 */
function firebaseTimestampToDate(timestamp) {
    if (!timestamp) return new Date();
    if (typeof timestamp === 'object' && timestamp.seconds) {
        return new Date(timestamp.seconds * 1000);
    }
    return new Date(timestamp);
}

/**
 * LocalStorage helper functions
 */
const StorageHelper = {
    setAdmin(admin) {
        localStorage.setItem('admin', JSON.stringify(admin));
    },

    getAdmin() {
        const admin = localStorage.getItem('admin');
        return admin ? JSON.parse(admin) : null;
    },

    setToken(token) {
        localStorage.setItem('adminToken', token);
    },

    getToken() {
        return localStorage.getItem('adminToken');
    },

    setEmail(email) {
        localStorage.setItem('adminEmail', email);
    },

    getEmail() {
        return localStorage.getItem('adminEmail');
    },

    clear() {
        localStorage.removeItem('adminToken');
        localStorage.removeItem('admin');
        localStorage.removeItem('adminEmail');
    }
};

/**
 * Sidebar toggle functionality
 */
if (document.getElementById('sidebarToggle')) {
    document.getElementById('sidebarToggle').addEventListener('click', () => {
        const nav = document.querySelector('.sidebar-nav');
        if (nav) {
            nav.classList.toggle('active');
        }
    });
}

/**
 * Close modals when clicking outside
 */
document.addEventListener('click', (e) => {
    if (e.target.classList.contains('modal')) {
        e.target.classList.remove('active');
        document.body.style.overflow = 'auto';
    }
});

/**
 * Add CSS animations
 */
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(400px);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }

    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(400px);
            opacity: 0;
        }
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);

console.log('✓ Admin Portal utilities loaded');
