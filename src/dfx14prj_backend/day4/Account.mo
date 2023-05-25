import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";

module {
  public type Subaccount = Blob;

  public type Account = {
    owner : Principal;
    subaccount : ?Subaccount;
  };

  public type AccountWithBalance = {
    owner : Principal;
    balance : Nat;
    subaccount : ?Subaccount;
  };

  public type DailyProject = {
    canisterId : Principal;
    day : Nat;
    timeStamp : Nat64;
  };

  public type Student = {
    bonusPoints : Nat;
    cliPrincipalId : Text;
    completedDays : DailyProject;
    name : Text;
    principalId : Text;
    score : Nat;
    teamName : Text;
  };

  func _getDefaultSubaccount() : Subaccount {
    Blob.fromArrayMut(Array.init(32, 0 : Nat8));
  };

  public func accountsEqual(lhs : Account, rhs : Account) : Bool {
    let lhsSubaccount : Subaccount = Option.get<Subaccount>(lhs.subaccount, _getDefaultSubaccount());
    let rhsSubaccount : Subaccount = Option.get<Subaccount>(rhs.subaccount, _getDefaultSubaccount());
    Principal.equal(lhs.owner, rhs.owner) and Blob.equal(lhsSubaccount, rhsSubaccount);
  };

  public func accountsHash(lhs : Account) : Nat32 {
    let lhsSubaccount : Subaccount = Option.get<Subaccount>(lhs.subaccount, _getDefaultSubaccount());
    let hashSum = Nat.add(Nat32.toNat(Principal.hash(lhs.owner)), Nat32.toNat(Blob.hash(lhsSubaccount)));
    Nat32.fromNat(hashSum % (2 ** 32 - 1));
  };

  public func accountWithBalancesEqual(lhs : AccountWithBalance, rhs : AccountWithBalance) : Bool {
    let lhsSubaccount : Subaccount = Option.get<Subaccount>(lhs.subaccount, _getDefaultSubaccount());
    let rhsSubaccount : Subaccount = Option.get<Subaccount>(rhs.subaccount, _getDefaultSubaccount());
    Principal.equal(lhs.owner, rhs.owner) and Blob.equal(lhsSubaccount, rhsSubaccount);
  };

  public func accountWithBalancesHash(lhs : AccountWithBalance) : Nat32 {
    let lhsSubaccount : Subaccount = Option.get<Subaccount>(lhs.subaccount, _getDefaultSubaccount());
    let hashSum = Nat.add(Nat32.toNat(Principal.hash(lhs.owner)), Nat32.toNat(Blob.hash(lhsSubaccount)));
    Nat32.fromNat(hashSum % (2 ** 32 - 1));
  };

  public func accountBelongToPrincipal(account : Account, principal : Principal) : Bool {
    Principal.equal(account.owner, principal);
  };
};
