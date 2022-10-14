using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(QuanlyRapphim.Startup))]
namespace QuanlyRapphim
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
