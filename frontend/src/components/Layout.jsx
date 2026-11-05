import Icon from './Icon'
import SiteFooter from './SiteFooter'

// Shared frame for both portals:
//   top bar  = logo + who is logged in + Log out
//   menu bar = only the pages this user may open (with an icon each)
//   page     = the current page
//   footer   = clinic offices and hours
export default function Layout({ title, account, items, current, onSelect, onLogout, children }) {
  const initials = account.username.slice(0, 2)

  return (
    <>
      <header className="site-header">
        <div className="site-header-inner">
          <button type="button" className="brand" onClick={() => onSelect('home')}>
            <span className="brand-mark"><Icon name="heartPulse" size={22} /></span>
            <span>
              Clarity Health
              <span className="brand-sub">{title}</span>
            </span>
          </button>

          <div className="user-chip">
            <span className="avatar">{initials}</span>
            <span className="user-text">
              <span className="user-name">{account.username}</span>
              <span className="user-role">{account.role}</span>
            </span>
            <button type="button" className="logout-button" onClick={onLogout}>
              <Icon name="logout" size={16} />
              Log out
            </button>
          </div>
        </div>
      </header>

      <nav className="site-nav" aria-label="Main menu">
        <div className="site-nav-inner">
          {items.map((item) => (
            <button
              key={item.key}
              type="button"
              className={item.key === current ? 'active' : ''}
              aria-current={item.key === current ? 'page' : undefined}
              onClick={() => onSelect(item.key)}
            >
              {item.icon && <Icon name={item.icon} size={18} />}
              {item.label}
            </button>
          ))}
        </div>
      </nav>

      <main className="page">{children}</main>

      <SiteFooter />
    </>
  )
}
