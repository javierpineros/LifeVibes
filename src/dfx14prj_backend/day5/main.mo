import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";

import Ic "Ic";
import HTTP "Http";
import Type "Types";

actor class Verifier() {
  type StudentProfile = Type.StudentProfile;
  type CalculatorInterface = Type.CalculatorInterface;

  type TestError = Type.TestError;
  type ErrorCode = Error.ErrorCode;

  stable var entries : [(Principal, StudentProfile)] = [];
  let iter = entries.vals();

  let studentProfileStore : HashMap.HashMap<Principal, StudentProfile> = HashMap.fromIter<Principal, StudentProfile>(iter, 10, Principal.equal, Principal.hash);

  let mbcStudentsCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
    getAllStudentsPrincipal : shared () -> async [Principal];
    getAllStudents : shared () -> async [Text];
    //getStudent : shared (Text) -> async Student;
  };

  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    studentProfileStore.put(
      caller,
      profile,
    );
    return #ok();
  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    let student : ?StudentProfile = studentProfileStore.get(p);
    switch (student) {
      case null {
        #err("Student does not exists");
      };
      case (?student) {
        #ok(student);
      };
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    let student : ?StudentProfile = studentProfileStore.get(caller);
    switch (student) {
      case null {
        #err("Student does not exists");
      };
      case (?student) {
        ignore studentProfileStore.replace(caller, student);
        #ok();
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    let student : ?StudentProfile = studentProfileStore.get(caller);
    switch (student) {
      case null {
        #err("Student does not exists");
      };
      case (?student) {
        studentProfileStore.delete(caller);
        #ok();
      };
    };
  };
  // STEP 1 - END

  // STEP 2 - BEGIN
  type calculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;

  // Calculator
  var counter : Int = 0;

  public func reset() : async Int {
    counter := 0;
    return counter;
  };

  public func add(x : Int) : async Int {
    counter += x;
    return counter;
  };

  public func sub(x : Int) : async Int {
    counter -= x;
    return counter;
  };

  public func test(canisterId : Principal) : async TestResult {
    Debug.print("Iniciando Test Calculator en IC");
    let canister : CalculatorInterface = actor (Principal.toText(canisterId));
    //let managementCanister : IC.ManagementCanisterInterface = actor ("aaaaa-aa");
    /*let canister = actor (Principal.toText(canisterId)) : actor {
      add : shared (n : Int) -> async Int;
      sub : shared (n : Int) -> async Int;
      reset : shared () -> async Int;
    };*/
    try {
      let _reset = await canister.reset();
      if (_reset != 0) {
        return #err(#UnexpectedValue("UnexpectedValue"));
      };

      let _add = await canister.add(1);
      if (_add != 1) {
        return #err(#UnexpectedValue("UnexpectedValue"));
      };

      let _sub = await canister.sub(1);
      if (_sub != 0) {
        return #err(#UnexpectedValue("UnexpectedValue"));
      };

    } catch e {
      let errorCode = Error.code(e);

      if (errorCode == #system_fatal) {
        return #err(#UnexpectedError("#UnexpectedError"));
      } else if (errorCode == #system_transient) {
        return #err(#UnexpectedError("#UnexpectedError"));
      } else if (errorCode == #canister_reject) {
        return #err(#UnexpectedError("#UnexpectedError"));
      } else if (errorCode == #canister_error) {
        return #err(#UnexpectedError("#UnexpectedError"));
      };
      return #err(#UnexpectedError("UnexpectedError: " # Error.message(e)));
    };
    return #ok();
  };
  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally

  public func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : async [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    return Buffer.toArray<Principal>(controllers);
  };

  public func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
    try {
      let controllers = await Ic.getCanisterControllers(canisterId);

      var isOwner : ?Principal = Array.find<Principal>(controllers, func prin = prin == p);
      
      if (isOwner != null) {
        return true;
      };

      return false;
    } catch (e) {
      return false;
    }
  };

  // STEP 3 - END

  // STEP 4 - BEGIN

  private func setGraduation(p : Principal, graduate : Bool) : async () {
    let student = studentProfileStore.get(p);
    switch (student) {
      case (null) {};
      case (?student) {
        let studentGraduated = {
          name = student.name;
          Team = student.Team;
          graduate = true;
        };
        ignore studentProfileStore.replace(p, studentGraduated);
      };
    };
  };

  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<Bool, Text> {
    let verifyCanister = actor (Principal.toText(canisterId)) : actor {
      addMyProfile : shared StudentProfile -> async Result.Result<(), Text>;
      updateMyProfile : shared StudentProfile -> async Result.Result<(), Text>;
      deleteMyProfile : shared () -> async Result.Result<(), Text>;
      seeAProfile : shared Principal -> async Result.Result<StudentProfile, Text>;

      //Part 2
      test : shared Principal -> async TestResult;

      //Part 3
      verifyOwnership : shared (Principal, Principal) -> async Result.Result<Bool, Text>;

      //Part 4
      verifyWork : shared (Principal, Principal) -> async Result.Result<(), Text>;
    };
    try {
      let _test = await test(canisterId);

      switch (_test) {
        case (#ok()) {};
        case (_) {
          return #err("Error in test() canister ");
        };
      };

      let owner = await verifyOwnership(canisterId, p);
      switch (owner) {
        case (true) {
          let student : ?StudentProfile = studentProfileStore.get(p);

          switch (student) {
            case null {
              return #err("The principal do not correspond to a registered student: " # Principal.toText(p));
            };
            case (?student) {
              var updatedStudent = {
                name = student.name;
                Team = student.Team;
                graduate = true;
              };
              ignore studentProfileStore.replace(p, updatedStudent);
              return #ok(true);
            };
          };
        };
        case (false) {
          await setGraduation(p, false);
        };
      };

      #ok(true);
    } catch (e) {
      await setGraduation(p, false);
      #err("Error verifying test or verifyWork: " # Error.message(e));
    };
  };
  // STEP 4 - END
  /*
  // STEP 5 - BEGIN
  public type HttpRequest = HTTP.HttpRequest;
  public type HttpResponse = HTTP.HttpResponse;

  // NOTE: Not possible to develop locally,
  // as Timer is not running on a local replica
  public func activateGraduation() : async () {
    return ();
  };

  public func deactivateGraduation() : async () {
    return ();
  };

  public query func http_request(request : HttpRequest) : async HttpResponse {
    return ({
      status_code = 200;
      headers = [];
      body = Text.encodeUtf8("");
      streaming_strategy = null;
    });
  };
  // STEP 5 -
  */

  system func preupgrade() {
    entries := Iter.toArray(studentProfileStore.entries());
  };

  system func postupgrade() {
    entries := [];
  };

  public shared ({ caller }) func getAllStudents() : async [Text] {
    let students = await mbcStudentsCanister.getAllStudents();
    return students;
  };

  public shared ({ caller }) func getAllProfiles() : async [StudentProfile] {
    return Iter.toArray(studentProfileStore.vals());
  };

  public shared ({ caller }) func getAllPrincipal() : async [Principal] {
    return Iter.toArray(studentProfileStore.keys());
  };

  public query func testJavison() : async () {
    Debug.print("Iniciando Test Calculator");
  };

  public func getMBCStudentPrincipals() : async Principal {
    let mbcStudentsCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
    };

    let mbcStudents : [Principal] = await mbcStudentsCanister.getAllStudentsPrincipal();

    return mbcStudents[0];
  };

};
