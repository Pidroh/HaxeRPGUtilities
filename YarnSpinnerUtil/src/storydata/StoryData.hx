typedef Message = {
    var body : String;
    var speaker : String;
  }
  
  typedef Cutscene = {
    var messages : Array<Message>;
    var title : String;
  }