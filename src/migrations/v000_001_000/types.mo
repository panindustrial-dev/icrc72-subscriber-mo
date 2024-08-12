import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Star "mo:star/star";
import VectorLib "mo:vector";
import BTreeLib "mo:stableheapbtreemap/BTree";
import SetLib "mo:map/Set";
import MapLib "mo:map/Map";
import TTLib "../../../../timerTool/src";
// please do not import any types from your project outside migrations folder here
// it can lead to bugs when you change those types later, because migration types should not be changed
// you should also avoid importing these types anywhere in your project directly from here
// use MigrationTypes.Current property instead


module {

  public let BTree = BTreeLib;
  public let Set = SetLib;
  public let Map = MapLib;
  public let Vector = VectorLib;
  public let TT = TTLib;

  public type Namespace = Text;

  public type ICRC16Property = {
    name : Text;
    value : ICRC16;
    immutable : Bool;
  };

  public type ICRC16 = {
    #Array : [ICRC16];
    #Blob : Blob;
    #Bool : Bool;
    #Bytes : [Nat8];
    #Class : [ICRC16Property];
    #Float : Float;
    #Floats : [Float];
    #Int : Int;
    #Int16 : Int16;
    #Int32 : Int32;
    #Int64 : Int64;
    #Int8 : Int8;
    #Map : [(Text, ICRC16)];
    #ValueMap : [(ICRC16, ICRC16)];
    #Nat : Nat;
    #Nat16 : Nat16;
    #Nat32 : Nat32;
    #Nat64 : Nat64;
    #Nat8 : Nat8;
    #Nats : [Nat];
    #Option : ?ICRC16;
    #Principal : Principal;
    #Set : [ICRC16];
    #Text : Text;
  };

  //ICRC3 Value
  public type Value = {
    #Nat : Nat;
    #Int : Int;
    #Text : Text;
    #Blob : Blob;
    #Array : [Value];
    #Map : [(Text, Value)];
  };

  public type ICRC16Map = [(Text, ICRC16)];

  public type NewEvent = {
    namespace : Text;
    data : ICRC16;
    headers : ?ICRC16Map;
  };

  public type EmitableEvent = {
    broadcaster: Principal;
    id : Nat;
    prevId : ?Nat;
    timestamp : Nat;
    namespace : Text;
    source : Principal;
    data : ICRC16;
    headers : ?ICRC16Map;
  };

  public type Event = {
    id : Nat;
    prevId : ?Nat;
    timestamp : Nat;
    namespace : Text;
    source : Principal;
    data : ICRC16;
    headers : ?ICRC16Map;
  };

  public type EventNotification = {
    id : Nat;
    eventId : Nat;
    prevEventId : ?Nat;
    timestamp : Nat;
    namespace : Text;
    data : ICRC16;
    source : Principal;
    headers : ?ICRC16Map;
    filter : ?Text;
  };

    

  public type ExecutionItem = {
    #Sync : ExecutionHandler;
    #Async : ExecutionAsyncHandler;
  };

  public type ExecutionHandler = <system>(EventNotification) -> ();
  public type ExecutionAsyncHandler = <system>(EventNotification) -> async* ();


  ///MARK: Constants
  public let CONST = {
    subscriber = {
      timers = {
        sendConfirmations = "icrc72:subscriber:timers:sendConfirmations";
      };
      sys = "icrc72:subscriber:sys:";
      broadcasters = {
        add = "icrc72:subscriber:broadcaster:add";
        remove = "icrc72:subscriber:broadcaster:remove";
        error = "icrc72:subscriber:broadcaster:error";
      };
    };
    broadcasters = {
      subscriber={
        broadcasters = {
          add = "icrc72:broadcaster:subscriber:broadcaster:add";
          remove = "icrc72:broadcaster:subscriber:broadcaster:remove";
        };
      }
    }

  };

  public type PublicationRegistration = {
    namespace : Text; // The namespace of the publication for categorization and filtering
    config : ICRC16Map; // Additional configuration or metadata about the publication
    memo: ?Blob;
    // publishers : ?[Principal]; // Optional list of publishers authorized to publish under this namespace
    // subscribers : ?[Principal]; // Optional list of subscribers authorized to subscribe to this namespace
    // mode : Nat; // Publication mode (e.g., sequential, ranked, etc.)
  };

  public type SubscriptionRegistration = {
    namespace : Text; // The namespace of the publication for categorization and filtering
    config : ICRC16Map; // Additional configuration or metadata about the publication
    memo: ?Blob;
  };

  public type SubscriptionRecord = {
    namespace : Text;
    config : ICRC16Map;
    id: Nat;
  };


  public type SubscriberInterface = {
    handleNotification : ([Nat]) -> async ();
    registerSubscription : (SubscriptionRegistration) -> async Nat;
  };

  public type ICRC75Item = {
    principal: Principal;
    namespace: Namespace
  };

  public type InitArgs ={
    name: Text;
  };

  public type Environment = {
    addRecord: ?(([(Text, Value)], ?[(Text,Value)]) -> Nat);
    generateId: ?((Text, State) -> Nat);
    icrc72OrchestratorCanister : Principal;
    tt: TT.TimerTool;
    handleNotificationError: ?(<system>(EventNotification, Error) -> ());
    handleEventOrder: ?(<system>(State, Environment, Nat, EventNotification) -> Bool);
  };

  ///MARK: State
  public type State = {
    broadcasters : BTree.BTree<Nat, Vector.Vector<Principal>>;
    var validBroadcasters : {
      #list : Set.Set<Principal>;
      #icrc75 : ICRC75Item;
    };
    confirmAccumulator: BTree.BTree<Principal, Vector.Vector<Nat>>;
    var confirmTimer: ?Nat;
    subscriptions : BTree.BTree<Nat, SubscriptionRecord>;
    subscriptionsByNamespace : BTree.BTree<Text, Nat>;
    lastEventId : BTree.BTree<Text, BTree.BTree<Nat, Nat>>; //IDUsed, BroadcasterUsed
    backlogs : BTree.BTree<Nat, BTree.BTree<Nat, EventNotification>>;
    var readyForSubscription: Bool;
    var error : ?Text;
  };
};