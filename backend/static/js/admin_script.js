const API_BASE_URL = window.location.origin; // Dynamically get base URL

function checkAuth() {
    const token = localStorage.getItem('adminToken');
    if (!token) {
        window.location.href = '/admin'; // Redirect to login
    }
}

async function handleLogin(event) {
    event.preventDefault();
    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const btn = document.getElementById('loginBtn');
    const msg = document.getElementById('errorMessage');

    btn.disabled = true;
    btn.innerHTML = 'Signing In...';
    msg.style.display = 'none';

    try {
        const response = await fetch(`${API_BASE_URL}/api/admin/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });

        const data = await response.json();

        if (response.ok) {
            localStorage.setItem('adminToken', data.token);
            localStorage.setItem('adminUser', JSON.stringify(data.user));
            window.location.href = '/admin/dashboard';
        } else {
            msg.textContent = data.msg || 'Login failed';
            msg.style.display = 'block';
            btn.disabled = false;
            btn.innerHTML = '<span class="btn-text">Sign In</span>';
        }
    } catch (error) {
        msg.textContent = 'Connection error. Please try again.';
        msg.style.display = 'block';
        btn.disabled = false;
        btn.innerHTML = '<span class="btn-text">Sign In</span>';
    }
}

async function handleAdminRegister(event) {
    event.preventDefault();
    const name = document.getElementById('name').value;
    const email = document.getElementById('email').value;
    const department = document.getElementById('department').value;
    const password = document.getElementById('password').value;
    const confirm = document.getElementById('confirmPassword').value;

    const btn = document.getElementById('registerBtn');
    const msg = document.getElementById('errorMessage');

    if (password !== confirm) {
        msg.textContent = 'Passwords do not match';
        msg.style.display = 'block';
        return;
    }

    btn.disabled = true;
    btn.innerHTML = 'Creating Account...';
    msg.style.display = 'none';

    try {
        const response = await fetch(`${API_BASE_URL}/api/admin/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name, email, department, password })
        });

        const data = await response.json();

        if (response.ok) {
            alert('Admin account created successfully! Please login.');
            window.location.href = '/admin';
        } else {
            msg.textContent = data.msg || 'Registration failed';
            msg.style.display = 'block';
            btn.disabled = false;
            btn.innerHTML = '<span class="btn-text">Create Account</span>';
        }
    } catch (error) {
        msg.textContent = 'Connection error. Please try again.';
        msg.style.display = 'block';
        btn.disabled = false;
        btn.innerHTML = '<span class="btn-text">Create Account</span>';
    }
}

function logout() {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminUser');
    window.location.href = '/admin';
}

let allReports = [];

async function loadDashboardData() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/requests`);
        const data = await response.json();

        if (data.requests) {
            allReports = data.requests;
            updateStats();
            renderTable(allReports);
        }
    } catch (error) {
        console.error('Error loading data:', error);
    }
}

function updateStats() {
    const total = allReports.length;
    const pending = allReports.filter(r => r.status === 'pending').length;
    // Handle 'in-progress' vs 'In Progress' vs 'in progress'
    const progress = allReports.filter(r => ['in-progress', 'in progress', 'processing'].includes(r.status?.toLowerCase())).length;
    const resolved = allReports.filter(r => ['resolved', 'completed', 'done'].includes(r.status?.toLowerCase())).length;

    document.getElementById('countTotal').innerText = total;
    document.getElementById('countPending').innerText = pending;
    document.getElementById('countProgress').innerText = progress;
    document.getElementById('countResolved').innerText = resolved;
}

function renderTable(reports) {
    const tbody = document.getElementById('reportsTableBody');
    tbody.innerHTML = '';

    if (reports.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;">No reports found</td></tr>';
        return;
    }

    reports.forEach(report => {
        const date = new Date(report.createdAt).toLocaleDateString();
        const tr = document.createElement('tr');

        // Determine status badge class
        let badgeClass = 'pending';
        const status = report.status ? report.status.toLowerCase() : 'pending';
        if (status.includes('progress')) badgeClass = 'in-progress';
        if (status.includes('resolve') || status.includes('complete')) badgeClass = 'resolved';

        tr.innerHTML = `
            <td>#${report.id.substring(0, 6)}...</td>
            <td>${date}</td>
            <td>${report.title}</td>
            <td>${report.department || '-'}</td>
            <td><span class="badge ${badgeClass}">${report.status}</span></td>
            <td>${report.priority}</td>
            <td class="actions-cell">
                <button class="view-btn" onclick="openDetails('${report.id}')">View</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

function filterReports() {
    const search = document.getElementById('searchInput').value.toLowerCase();
    const status = document.getElementById('statusFilter').value;
    const dept = document.getElementById('deptFilter').value;

    const filtered = allReports.filter(report => {
        const matchesSearch = (report.title && report.title.toLowerCase().includes(search)) ||
            (report.description && report.description.toLowerCase().includes(search));

        // Status filter logic
        let matchesStatus = true;
        if (status !== 'all') {
            const rStatus = report.status ? report.status.toLowerCase() : 'pending';
            if (status === 'resolved') matchesStatus = rStatus.includes('resolve') || rStatus.includes('complete');
            else if (status === 'in-progress') matchesStatus = rStatus.includes('progress');
            else matchesStatus = rStatus === status;
        }

        const matchesDept = dept === 'all' || (report.department === dept);

        return matchesSearch && matchesStatus && matchesDept;
    });

    renderTable(filtered);
}

function openDetails(id) {
    const report = allReports.find(r => r.id === id);
    if (!report) return;

    const modal = document.getElementById('detailsModal');
    const body = document.getElementById('modalBody');

    // Build images HTML
    let imagesHtml = '';
    if (report.images && report.images.length > 0) {
        imagesHtml = '<div class="report-images">';
        report.images.forEach(img => {
            // Handle if path is full url or relative
            // If relative (e.g., 'uploads/xxx.jpg'), prepend base url implicitly or explicitly
            // Based on backend config, it's served at /uploads/...
            const src = img.startsWith('http') ? img : `/${img}`;
            imagesHtml += `<a href="${src}" target="_blank"><img src="${src}" alt="Report Image"></a>`;
        });
        imagesHtml += '</div>';
    } else {
        imagesHtml = '<p>No images attached.</p>';
    }

    body.innerHTML = `
        <div class="modal-header">
            <h2>${report.title} <span class="badge">${report.status}</span></h2>
            <p>Report ID: ${report.id}</p>
        </div>
        
        <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 20px;">
            <div>
                <h3>Description</h3>
                <p>${report.description}</p>
                
                <h3>Location</h3>
                <p>${report.location_text || 'No location text'}</p>
                <p><strong>Landmark:</strong> ${report.landmark || '-'}</p>
            </div>
            <div>
                <h3>Details</h3>
                <p><strong>Department:</strong> ${report.department}</p>
                <p><strong>Priority:</strong> ${report.priority}</p>
                <p><strong>Reporter:</strong> ${report.reporter_name || 'Anonymous'}</p>
                <p><strong>Contact:</strong> ${report.reporter_email || '-'}</p>
                <p><strong>Date:</strong> ${new Date(report.createdAt).toLocaleString()}</p>
            </div>
        </div>

        <h3>Evidence</h3>
        ${imagesHtml}

        <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
            <h3>Update Status</h3>
            <button onclick="updateStatus('${report.id}', 'pending')" class="status-u-btn" style="background:#F59E0B">Mark Pending</button>
            <button onclick="updateStatus('${report.id}', 'processing')" class="status-u-btn" style="background:#2563EB">Mark In Progress</button>
            <button onclick="updateStatus('${report.id}', 'resolved')" class="status-u-btn" style="background:#10B981">Mark Resolved</button>
        </div>
    `;

    modal.style.display = "block";
}

async function updateStatus(id, newStatus) {
    if (!confirm(`Are you sure you want to mark this report as ${newStatus}?`)) return;

    try {
        const response = await fetch(`${API_BASE_URL}/api/requests/${id}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ status: newStatus })
        });

        if (response.ok) {
            // Update local data and re-render
            const rIndex = allReports.findIndex(r => r.id === id);
            if (rIndex > -1) {
                allReports[rIndex].status = newStatus;
                updateStats();
                filterReports(); // Re-render table
                closeModal();
            }
            alert('Status updated successfully');
        } else {
            alert('Failed to update status');
        }
    } catch (e) {
        console.error(e);
        alert('Error updating status');
    }
}

function closeModal() {
    document.getElementById('detailsModal').style.display = "none";
}

function refreshData() {
    loadDashboardData();
}

// Close modal when clicking outside
window.onclick = function (event) {
    const modal = document.getElementById('detailsModal');
    if (event.target == modal) {
        modal.style.display = "none";
    }
}
