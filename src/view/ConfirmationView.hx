import haxe.macro.Expr.Function;
import haxe.ui.components.Button;
import haxe.ui.components.Label;
import haxe.ui.containers.VBox;
import haxe.ui.core.Component;

class PrivacyConfirmationView
{
    public static function CreateView(acceptFunction) : Component{
        var mainView = new VBox();
        mainView.padding = 40;
        var title = new Label();
        mainView.addComponent(title);
        title.htmlText = "<h2>We collect log data to make the game better!</h2>";
        var subtext = new Label();
        mainView.addComponent(subtext);
        subtext.text = "Please accept our Privacy Policy and Terms of Use";
        AddLink(mainView, "Privacy Policy and Terms of Use","https://github.com/Pidroh/TOS_Privacy");



        {
            var button = new Button();
            button.text = "Accept";
            button.onClick = function(e){
                acceptFunction();
            };
            button.width = 150;
            button.paddingTop = 20;
            mainView.addComponent(button);
        }
        //AddButton(mainView, "Accept", acceptFunction);
        return mainView;
    }

    public static function AddLink(parent : Component, text, url) {
        var label = new Label();
        parent.addComponent(label);
        label.htmlText = '<a href="$url" target = "_blank">$text</a>';
    }
}
