import { useEffect, useState } from 'react'
import { api } from '../../api/client'

const wait = (ms) => new Promise((resolve) => setTimeout(resolve,ms)) 
// Login card (moved out of App.jsx) + the "Create an account" link for new patients
export default function Login({ onLoggedIn, onSignUp, notice }) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  const [waking, setWaking] = useState(false)

  useEffect(() =>{
    let stopped = false

    async function wakeUp() {
      for(let attempt = 1; attempt <= 12; attempt++){
        if(stopped){return}
        try{
          await api.health()
          if(!stopped){setWaking(false)}
          return
        }
        catch{
          if(stopped){return}
          setWaking(true)
          await wait(5000)
        }
      }
      if(!stopped){setWaking(false)}
    }

    wakeUp()
    return () => {stopped = true}
  }, [])
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
      let account
      try {
        account = await api.login(username, password)       // { accountID, userID, username, role }
      } catch (e) {
        if (e.status >= 500) {                              // database still waking up: try once more
          await wait(5000)
          account = await api.login(username, password)
        } else {
          throw e                                           // 401 wrong password etc. → straight to the message
        }
      }
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
        <h1>Clarity Health</h1>

        {notice && <p className="login-notice">{notice}</p>}
        {waking && <p className="login-notice">Waking up the server… this can take up to a minute.</p>}
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
