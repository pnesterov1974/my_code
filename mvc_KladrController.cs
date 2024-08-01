using Microsoft.AspNetCore.Mvc;
using adodb;

namespace webapi
{

    [ApiController]
    [Route("api/[controller]")]
    public class KladrController : ControllerBase
    {  
        public static IConfigurationRoot config = new ConfigurationBuilder()
                 .AddJsonFile("appsettings.json")
                 .SetBasePath(Directory.GetCurrentDirectory())
                 .Build();
        public static string connStr = config.GetConnectionString("DefaultConnection");
        
        [HttpGet]
        [Route("/socrbase")]
        public string GetSocrBase()
        {
            SocrBaseReader sbr = new SocrBaseReader(KladrController.connStr);
            return sbr.DataAsJson;
        }

        [HttpGet]
        [Route("/altnames")]
        public string GetAltNames()
        {
            AltNamesReader alr = new AltNamesReader(KladrController.connStr);
            return alr.DataAsJson;
        }

        [HttpGet]
        [Route("/kladr")]
        public string GetKladr()
        {
            KladrReader klr = new KladrReader(KladrController.connStr);
            return klr.DataAsJson;
        }

        [HttpGet]
        [Route("/street")]
        public string  GetStreet()
        {
            StreetReader str = new StreetReader(KladrController.connStr);
            return str.DataAsJson;
        }

        [HttpGet]
        [Route("/doma")]
        public string GetDoma()
        {
            DomaReader dmr = new DomaReader(KladrController.connStr);
            return dmr.DataAsJson;
        }

        [HttpGet]
        [Route("/kladr_actual")]
        public string GetKladrActual()
        {
            KladrActualReader klar = new KladrActualReader(KladrController.connStr);
            return klar.DataAsJson;
        }

        [HttpGet]
        [Route("/street_actual")]
        public string GetStreetActual()
        {
            StreetActualReader star = new StreetActualReader(KladrController.connStr);
            return star.DataAsJson;
        }
    }
}
