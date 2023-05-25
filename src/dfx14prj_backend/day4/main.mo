import Array "mo:base/Array";
import Buffer "mo:base/Buffer";

import HashMap "mo:base/HashMap";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";
import Trie "mo:base/Trie";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
import Prim "mo:prim";

import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";

import Account "Account";
import Student "Account";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
import BootcampLocalActor "BootcampLocalActor";

actor class MotoCoin() {
  type Principal = Prim.Types.Principal;

  public type Account = Account.Account;
  public type AccountWithBalance = Account.AccountWithBalance;
  public type Student = Account.Student;

  var ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);

  // Returns the name of the token
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    var total = 0;
    for (accountBalance : Nat in ledger.vals()) {
      total += accountBalance;
    };
    return total;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    let balance = ledger.get(account);
    switch (balance) {
      case null {
        return 0;
      };
      case (?balance) {
        return balance;
      };
    };
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    let balanceFrom = ledger.get(from);
    let balanceTo = ledger.get(to);

    switch (balanceFrom) {
      case null {
        return #err("from account doesn´t exists");
      };
      case (?balanceFrom) {
        switch (balanceTo) {
          case null {
            return #err("from account doesn´t exists");
          };
          case (?balanceTo) {
            ledger.put(from, balanceFrom - amount);
            ledger.put(from, balanceTo - amount);
            return #ok;
          };
        };
      };
    };
  };

  // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop0() : async Result.Result<(), Text> {
    let mbcStudentsCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
    };

    let mbcStudents : [Principal] = await mbcStudentsCanister.getAllStudentsPrincipal();

    var index : Nat = 0;
    let mbcStudentsIter = Iter.range(0, mbcStudents.size() - 1);

    var mbcPrincipalsHashMap : HashMap.HashMap<Principal, Principal> = HashMap.HashMap<Principal, Principal>(1, Principal.equal, Principal.hash);

    Debug.print("Generating mbcPrincipalsHashMap");
    for (studentId in mbcStudentsIter) {
      Debug.print("Principal " # Nat.toText(studentId));
      mbcPrincipalsHashMap.put(mbcStudents[studentId], mbcStudents[studentId]);
    };
    Debug.print("mbcPrincipalsHashMap Generated");

    Debug.print("Processing ledger accounts");
    for (account : Account in ledger.keys()) {
      let principal = mbcPrincipalsHashMap.get(account.owner);

      switch (principal) {
        case null {};
        case (?principal) {
          Debug.print("Principal " # Principal.toText(principal));
          let mbcAccountMap = TrieMap.mapFilter<Account, Nat, Nat>(
            ledger,
            Account.accountsEqual,
            Account.accountsHash,
            func(key : Account, value : Nat) {
              if (key.owner == principal) { ?value } else { null };
            },
          );
          //let _account = Option.
          let mbcAccount : ?Account = mbcAccountMap.keys().next();
          switch (mbcAccount) {
            case null {
              Debug.print("Principal not found in ledger");
            };
            case (?mbcAccount) {
              Debug.print("Principal found");
              let prevBalance = ledger.get(mbcAccount);
              switch (prevBalance) {
                case null {};
                case (?prevBalance) {
                  Debug.print("updating account balance to " # Nat.toText(prevBalance + 1000));
                  ignore ledger.replace(mbcAccount, prevBalance + 1000);
                };
              };
            };
          };
        };
      };

    };

    return #ok;
  };

  public func getMBCStudentPrincipals() : async [Principal] {
    let mbcStudentsCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
    };

    let mbcStudents : [Principal] = await mbcStudentsCanister.getAllStudentsPrincipal();
   
    return mbcStudents;
  };

  public func getMBCStudents() : async [Student] {
    let mbcStudentsCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
      getAllStudents : shared () -> async [Student];
    };

    let mbcStudents : [Student] = await mbcStudentsCanister.getAllStudents();
   
    return mbcStudents;
  };

  public func getMBCStudent(principal: Text) : async Student {
    let mbcStudentsCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
      getAllStudents : shared () -> async [Student];
      getStudent : shared (Text) -> async Student;
    };

    let mbcStudent : Student = await mbcStudentsCanister.getStudent(principal);
   
    return mbcStudent;
  };


  public func airdrop() : async Result.Result<(), Text> {
    let mbcStudentsCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
    };

    let mbcStudents : [Principal] = await mbcStudentsCanister.getAllStudentsPrincipal();

    var index : Nat = 0;
    let mbcStudentsIter = Iter.range(0, mbcStudents.size() - 1);

    var mbcPrincipalsHashMap : HashMap.HashMap<Principal, Principal> = HashMap.HashMap<Principal, Principal>(1, Principal.equal, Principal.hash);

    Debug.print("Generating mbcPrincipalsHashMap");
    for (studentId in mbcStudentsIter) {
      Debug.print("Principal " # Nat.toText(studentId));
      mbcPrincipalsHashMap.put(mbcStudents[studentId], mbcStudents[studentId]);

      let account: Account = {
        owner = mbcStudents[studentId];
        subaccount = null;
      };
      ledger.put(account, 100);
    };
    Debug.print("mbcPrincipalsHashMap Generated");

    //return Iter.toArray(ledger.keys());
    #ok();
  };

};
