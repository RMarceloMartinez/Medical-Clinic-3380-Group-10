import { useState } from 'react'
import { api } from './api'

// Login card (moved out of App.jsx) + the "Create an account" link for new patients
export default function Login({ onLoggedIn, onSignUp, notice }) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)

  async function handleLogin() {
    setError('')
    if (username === '') {
      setError('Please enter your username.')
      return
    }
    if (password === '') {
      setError('Please enter your password.')
      return
    }

    setBusy(true)
    try {
      const account = await api.login(username, password)   // { accountID, userID, username, role }
      onLoggedIn(account)
    } catch (e) {
      setError(e.message)
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="Login-screen">
      <div className="login-card">
        <h1>Medical Clinic</h1>

        {notice && <p className="login-notice">{notice}</p>}

        <input
          type="text"
          placeholder="Username"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
        />
        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          onKeyDown={(e) => { if (e.key === 'Enter') handleLogin() }}
        />

        {error && <p className="login-error">{error}</p>}

        <button type="button" onClick={handleLogin} disabled={busy}>
          {busy ? 'Logging in…' : 'Log In'}
        </button>

        <p className="login-signup">
          New patient?{' '}
          <button type="button" className="link-button" onClick={onSignUp}>
            Create an account
          </button>
        </p>
      </div>
    </div>
  )
}
