import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import Icon from '../../components/Icon'
import PublicHeader from '../../components/PublicHeader'
import SiteFooter from '../../components/SiteFooter'

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
    <>
      <PublicHeader>
        <button type="button" className="secondary-button" onClick={onSignUp}>
          New patient
        </button>
      </PublicHeader>

      {/* Hero: welcome text on the left, sign-in card on the right */}
      <section className="hero">
        <div className="hero-inner">
          <div>
            <span className="eyebrow">Houston family and specialty care</span>
            <h1>Care that fits your life</h1>
            <p className="hero-text">
              See your primary doctor, get referred to a specialist, and manage your visits and
              bills online, all in one place.
            </p>
            <div className="hero-actions">
              <button type="button" className="primary-button" onClick={onSignUp}>
                Create a patient account
              </button>
            </div>
            <div className="hero-facts">
              <span><Icon name="mapPin" size={16} /> 2 Houston offices</span>
              <span><Icon name="clock" size={16} /> Open Monday to Friday</span>
              <span><Icon name="calendar" size={16} /> Book online any time</span>
            </div>
          </div>

          <div className="login-card">
            <h2>Sign in</h2>
            <p className="card-intro">Patients and staff use the same sign-in.</p>

            {notice && <p className="login-notice">{notice}</p>}
            {waking && <p className="login-notice">Waking up the server… this can take up to a minute.</p>}

            <label htmlFor="username">Username</label>
            <input
              id="username"
              type="text"
              placeholder="Username"
              autoComplete="username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
            />
            <label htmlFor="password">Password</label>
            <input
              id="password"
              type="password"
              placeholder="Password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              onKeyDown={(e) => { if (e.key === 'Enter') handleLogin() }}
            />

            {error && <p className="login-error">{error}</p>}

            <button type="button" className="primary-button" onClick={handleLogin} disabled={busy}>
              {busy ? 'Logging in…' : 'Log in'}
            </button>

            <p className="login-signup">
              New patient?{' '}
              <button type="button" className="link-button" onClick={onSignUp}>
                Create an account
              </button>
            </p>
          </div>
        </div>
      </section>

      {/* What the clinic offers */}
      <section className="section">
        <h2 className="section-title">How can we help?</h2>
        <p className="section-intro">
          Start with your primary doctor. When you need a specialist, they refer you and you book
          the visit right here.
        </p>
        <div className="service-cards">
          <div className="service-card">
            <span className="icon-circle"><Icon name="stethoscope" size={26} /></span>
            <h3>Primary care</h3>
            <p>Family Medicine, Internal Medicine and Pediatrics. Your first stop for any health question.</p>
          </div>
          <div className="service-card">
            <span className="icon-circle orange"><Icon name="heartPulse" size={26} /></span>
            <h3>Specialist care</h3>
            <p>Cardiology, Dermatology and Orthopedics, with a referral from your primary doctor.</p>
          </div>
          <div className="service-card">
            <span className="icon-circle"><Icon name="calendar" size={26} /></span>
            <h3>Online patient portal</h3>
            <p>Book visits, see upcoming appointments and check your balance any time.</p>
          </div>
        </div>
      </section>

      <SiteFooter />
    </>
  )
}
