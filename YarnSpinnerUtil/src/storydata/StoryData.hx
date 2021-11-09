typedef Message = {
    var body : String;
    var speaker : String;
    var script : String;
  }
  
  typedef Cutscene = {
    var messages : Array<Message>;
    var title : String;
    var visibilityScript : String;
    var actionLabel : String;
  }