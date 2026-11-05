import Icon from './Icon'

// Top bar for the pages people see before logging in (login, sign-up).
// Whatever you put between <PublicHeader> and </PublicHeader> shows on the right.
export default function PublicHeader({ children }) {
  return (
    <header className="site-header">
      <div className="site-header-inner">
        <div className="brand">
          <span className="brand-mark"><Icon name="heartPulse" size={22} /></span>
          <span>
            Clarity Health
            <span className="brand-sub">Family and specialty care</span>
          </span>
        </div>
        {children}
      </div>
    </header>
  )
}
