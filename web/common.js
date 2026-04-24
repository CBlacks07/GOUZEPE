/* common.js - shared auth, api and ui helpers */
(() => {
  const $ = (s) => document.querySelector(s);
  const $$ = (s) => Array.from(document.querySelectorAll(s));

  const defaultApi = () => {
    const host = location.hostname || 'localhost';
    return `http://${host}:3005`;
  };

  const getAPI = () => (localStorage.getItem('efoot.api') || defaultApi()).replace(/\/+$/, '');
  const getToken = () => localStorage.getItem('efoot.token') || '';
  const getRole = () => (localStorage.getItem('efoot.role') || 'member').toLowerCase();
  const getExp = () => Number(localStorage.getItem('efoot.expAt') || 0);

  const toast = (msg) => {
    const status = $('#status');
    if (!status) {
      console.log(msg);
      return;
    }
    status.textContent = msg;
    status.style.opacity = '1';
    setTimeout(() => { status.style.opacity = '0.75'; }, 1200);
  };

  async function safeFetch(url, options = {}, timeoutMs = 8000) {
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), timeoutMs);
    try {
      return await fetch(url, { ...options, signal: ctrl.signal });
    } finally {
      clearTimeout(timer);
    }
  }

  async function clearCaches() {
    try {
      const keep = new Set(['efoot.theme', 'efoot.api']);
      for (let i = localStorage.length - 1; i >= 0; i -= 1) {
        const key = localStorage.key(i);
        if (key && !keep.has(key)) {
          localStorage.removeItem(key);
        }
      }
      try { sessionStorage.clear(); } catch (_e) { }
      if ('caches' in window) {
        const keys = await caches.keys();
        for (const key of keys) {
          await caches.delete(key);
        }
      }
    } catch (_e) {
      // ignore cache clear issues
    }
  }

  async function logout() {
    const token = getToken();
    try {
      await fetch(`${getAPI()}/auth/logout`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` }
      });
    } catch (_e) {
      // ignore logout api errors
    }

    await clearCaches();
    setTimeout(() => location.replace('login.html'), 150);
  }

  function requireAdmin() {
    if (getRole() !== 'admin') {
      location.replace('Accueil.html');
    }
  }

  async function apiRequest(method, endpoint, data) {
    const res = await fetch(`${getAPI()}${endpoint}`, {
      method,
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${getToken()}`
      },
      body: data ? JSON.stringify(data) : undefined
    });

    if (!res.ok) {
      throw new Error(`HTTP ${res.status}`);
    }

    const text = await res.text();
    return text ? JSON.parse(text) : null;
  }

  const apiGet = (endpoint) => apiRequest('GET', endpoint);
  const apiPost = (endpoint, data) => apiRequest('POST', endpoint, data);
  const apiPut = (endpoint, data) => apiRequest('PUT', endpoint, data);
  const apiDelete = (endpoint) => apiRequest('DELETE', endpoint);

  function ensureFavicon() {
    const head = document.head;
    if (!head) return;

    if (!head.querySelector('link[rel~="icon"], link[rel="shortcut icon"]')) {
      const icon = document.createElement('link');
      icon.rel = 'icon';
      icon.type = 'image/png';
      icon.href = 'assets/icons/apple-touch-icon.png';
      head.appendChild(icon);
    }

    if (!head.querySelector('meta[name="theme-color"]')) {
      const meta = document.createElement('meta');
      meta.name = 'theme-color';
      meta.content = '#0b1220';
      head.appendChild(meta);
    }
  }

  function initApiStorage() {
    if (!localStorage.getItem('efoot.api')) {
      localStorage.setItem('efoot.api', defaultApi());
    }
  }

  function guard() {
    const filename = (location.pathname.split('/').pop() || '').toLowerCase();
    if (filename === 'login.html' || filename === 'debug-auth.html') {
      return;
    }

    const token = getToken();
    const exp = getExp();

    if (!token || (exp > 0 && Date.now() >= exp)) {
      location.replace('login.html');
      return;
    }

    if (filename.startsWith('admin-')) {
      const isAdmin = getRole() === 'admin';
      const memberAllowed = filename === 'admin-joueurs.html';
      if (!isAdmin && !memberAllowed) {
        location.replace('Accueil.html');
      }
    }
  }

  function initTheme() {
    const key = 'efoot.theme';
    const btn = $('#themeBtn') || $('#theme');

    const apply = (mode) => {
      const isLight = mode === 'light';
      document.documentElement.classList.toggle('light', isLight);
      localStorage.setItem(key, isLight ? 'light' : 'dark');

      if (!btn) return;

      const sun = btn.querySelector('.theme-icon-sun');
      const moon = btn.querySelector('.theme-icon-moon');
      if (sun && moon) {
        sun.style.display = isLight ? 'none' : 'inline-block';
        moon.style.display = isLight ? 'inline-block' : 'none';
      } else {
        btn.textContent = isLight ? 'Moon' : 'Sun';
      }
    };

    apply(localStorage.getItem(key) || 'dark');

    if (btn) {
      btn.addEventListener('click', () => {
        const next = document.documentElement.classList.contains('light') ? 'dark' : 'light';
        apply(next);
      });
    }
  }

  function initMenu() {
    const toggle = $('#menuToggle');
    const menu = $('#menu') || $('.menu');

    if (!toggle || !menu) return;

    const closeMenu = () => {
      menu.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
    };

    const openMenu = () => {
      menu.classList.add('open');
      toggle.setAttribute('aria-expanded', 'true');
    };

    toggle.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      if (menu.classList.contains('open')) closeMenu();
      else openMenu();
    });

    document.addEventListener('click', (e) => {
      if (!menu.classList.contains('open')) return;
      if (menu.contains(e.target) || toggle.contains(e.target)) return;
      closeMenu();
    });

    menu.querySelectorAll('a,button').forEach((el) => {
      el.addEventListener('click', () => {
        if (window.innerWidth <= 900) {
          closeMenu();
        }
      });
    });
  }

  function initUiBindings() {
    if (window.lucide && typeof window.lucide.createIcons === 'function') {
      window.lucide.createIcons();
    }

    const isAdmin = getRole() === 'admin';
    $$('.adminOnly, .adminNav').forEach((el) => {
      el.style.display = isAdmin ? '' : 'none';
    });

    const current = location.pathname.split('/').pop() || 'Accueil.html';
    $$('.menu a').forEach((link) => {
      const href = link.getAttribute('href') || '';
      if (href.includes(current)) {
        link.classList.add('active');
      }
    });

    const logoutBtn = $('#logoutBtn');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', async () => {
        if (!confirm('Voulez-vous vraiment vous deconnecter ?')) return;
        await logout();
      });
    }
  }

  // expose globals used by existing pages
  window.$ = $;
  window.$$ = $$;
  window.API = getAPI();
  window.token = getToken();
  window.role = getRole();
  window.expAt = getExp();
  window.logout = logout;
  window.getApiBase = getAPI;
  window.apiGet = apiGet;
  window.apiPost = apiPost;
  window.apiPut = apiPut;
  window.apiDelete = apiDelete;
  window.App = {
    $,
    $$,
    getAPI,
    getToken,
    getRole,
    getExp,
    toast,
    safeFetch,
    logout,
    requireAdmin
  };

  ensureFavicon();
  initApiStorage();
  guard();

  document.addEventListener('DOMContentLoaded', () => {
    initTheme();
    initMenu();
    initUiBindings();
  });
})();
