async function getCsrfToken() {
    const res = await fetch("/api/auth/csrf", { credentials : 'include' })
    if(!res.ok) return null
    const data = await res.json()
    return data.token
}
function errorMessage(data, status) {
    if(data?.message) return data.message
    if(data?.errors){
        const first = Object.values(data.errors)[0]
        if(Array.isArray(first) && first.length > 0) return first[0]
    }
    if (status === 401) return 'Please log in again.'
    if (status === 403) return 'You do not have permission to do that.'
    if (status === 404) return 'Not found.'
    return 'Something went wrong. Please try again.'
}

async function request(path, { method = 'GET', body } = {}) {
    const headers = {}

    if (body !== undefined) {
        headers['Content-Type'] = 'application/json'
    }

    if (method !== 'GET') {
        const token = await getCsrfToken()
        if (token) {
            headers['X-CSRF-TOKEN'] = token
        }
    }

    const res = await fetch(`/api${path}`, {
        method,
        headers,
        credentials: 'include',
        body: body !== undefined ? JSON.stringify(body) : undefined,
    })

    if (res.status === 204) return null

    const data = await res.json().catch(() => null)

    if (!res.ok) {
        const error = new Error(errorMessage(data, res.status))
        error.status = res.status
        throw error
    }

    return data
}

export const api = {
    get: (path) => request(path),
    post: (path, body) => request(path, { method: 'POST', body }),
    put: (path, body) => request(path, { method: 'PUT', body }),
    delete: (path) => request(path, { method: 'DELETE' }),

    login: (username, password) =>
        request('/auth/login', { method: 'POST', body: { username, password } }),
    logout: () => request('/auth/logout', { method: 'POST' }),
    me: () => request('/auth/me'),
}