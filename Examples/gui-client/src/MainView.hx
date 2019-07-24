package;
import haxe.ui.components.Button;
import haxe.ui.core.Component;

@:build(haxe.ui.macros.ComponentMacros.build("assets/main.xml"))
class MainView extends Component {
    private static var nextId:Int = 0;

    public function new() {
        super();
        percentWidth = 100;
        percentHeight = 100;

        for (i in 0...2) {
            addClient();
        }
    }

    private function addClient() {
        nextId++;
        trace("adding client");
        var client = new Client(nextId);
        //client.b.text = "" + nextId;
        //var client = new Button();
        //client.text = "bob";
        clientScrollview.addComponent(client);
    }
}
