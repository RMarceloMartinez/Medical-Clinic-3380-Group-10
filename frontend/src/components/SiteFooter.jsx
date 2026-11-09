import Icon from './Icon'

// Dark footer shown on every page: who we are, where, and when.
// The offices and hours match the sample data in database/seed.sql.
export default function SiteFooter() {
  return (
    <footer className="site-footer">
      <div className="site-footer-inner">
        <div>
          <p className="footer-brand">Clarity Health</p>
          <p>Primary and specialty care for the whole family in Houston.</p>
        </div>

        <div>
          <h4>Our offices</h4>
          <p><Icon name="mapPin" size={16} /> 1234 Main Street, Houston</p>
          <p><Icon name="mapPin" size={16} /> 5678 Westheimer Road, Houston</p>
        </div>

        <div>
          <h4>Office hours</h4>
          <p><Icon name="clock" size={16} /> Main Street: Mon – Fri, 8 am – 5 pm</p>
          <p><Icon name="clock" size={16} /> Westheimer: Mon – Fri, 9 am – 6 pm</p>
        </div>

        <div>
          <h4>New patients</h4>
          <p>Create an account online and book your first visit with a primary care doctor.</p>
        </div>
      </div>

      <div className="site-footer-bottom">
        © 2026 Clarity Health · COSC 3380 class project, not a real clinic
      </div>
    </footer>
  )
}
