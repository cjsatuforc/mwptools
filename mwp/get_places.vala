public class Places :  GLib.Object
{
    public struct PosItem
    {
        string name;
        double lat;
        double lon;
    }

    private PosItem[]pls = {};

    private void parse_csv(string fn)
    {
        var file = File.new_for_path(fn);
        try {
            var dis = new DataInputStream(file.read());
            string line;
            while ((line = dis.read_line (null)) != null)
            {
                if(line.strip().length > 0 &&
                   !line.has_prefix("#") &&
                   !line.has_prefix(";"))
                {
                    var parts = line.split(",");
                    if(parts.length == 3)
                    {
                        var p = PosItem();
                        p.lat = double.parse(parts[1]);
                        p.lon = double.parse(parts[2]);
                        p.name = parts[0];
                        pls += p;
                    }
                }
            }
        } catch (Error e) {
            error ("%s", e.message);
        }
    }

    private void parse_json(string fn)
    {
        try {
            var parser = new Json.Parser ();
            parser.load_from_file (fn);
            var root_object = parser.get_root ().get_object ();
            foreach (var node in
                     root_object.get_array_member ("places").get_elements ())
            {
                var p = PosItem();
                var item = node.get_object ();
                p.name = item.get_string_member("name");
                p.lat = item.get_double_member("lat");
                p.lon = item.get_double_member("lon");
                pls += p;
            }
        } catch (Error e) {
            error ("%s", e.message);
        }
    }

    public PosItem[] get_places(double dlat,double dlon)
    {
        string? fn;
        pls +=  PosItem(){name="Default", lat=dlat, lon=dlon};

        fn = MWPUtils.find_conf_file("places.json");
        if(fn != null)
            parse_json(fn);
        else if((fn = MWPUtils.find_conf_file("places")) != null)
        {
            parse_csv(fn);
        }
        return pls;
    }
}

/*************
public int main(string?[]args)
{
    var p = new Places(50.9, -1.53);
    var pl = p.get_places();
    foreach(var l in pl)
    {
        print ("Key %s = %f %f\n",l.name, l.lat, l.lon);
    }
    return 0;
}
*****************/