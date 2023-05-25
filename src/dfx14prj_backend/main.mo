import Prim "mo:⛔";
import HashMap "mo:base/HashMap";
import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Option "mo:base/Option";
import Bool "mo:base/Bool";

import Ic "Ic";
import HTTP "Http";
import Type "Types";
import Account "day4/Account";

actor class GraffiToko() {
  type TestError = Type.TestError;
  type ErrorCode = Error.ErrorCode;

  public query func greet(name : Text) : async Text {
    return "Hello, " # name # "!";
  };

  // ==============================================================
  // Avatar Wall
  // ==============================================================
  type Avatar = Type.Avatar;
  type AvatarImage = Type.AvatarImage;

  stable var avatarCounter : Nat = 0;
  stable var avatarEntries : [(Avatar)] = [];
  let avatarIter = avatarEntries.vals();
  let avatarBufferStore : Buffer.Buffer<Avatar> = Buffer.fromIter<Avatar>(avatarIter);

  stable var avatarImageCounter : Nat = 0;
  stable var avatarImageEntries : [(AvatarImage)] = [];
  let avatarImageIter = avatarImageEntries.vals();
  let avatarImageBufferStore : Buffer.Buffer<AvatarImage> = Buffer.fromIter<AvatarImage>(avatarImageIter);

  public shared /*({ caller })*/ func addAvatar(
    caller : Principal,
    name : Text,
    description : Text,
    image : Text,
  ) : async Int {
    Debug.print("Caller: " # Principal.toText(caller) # "");
    // Get userProfile
    let student : ?StudentProfile = studentProfileHashMapStore.get(caller);
    switch (student) {
      case null { return -1 };
      case (?student) {
        avatarBufferStore.insert(
          0,
          {
            id = avatarCounter;
            owner = caller;
            ownerName = student.nickname;
            name = name;
            description = description;
            subAvatar = null;
            votes = 0;
          },
        );

        avatarImageBufferStore.insert(
          0,
          {
            id = avatarCounter;
            owner = caller;
            image = image;
            subAvatar = null;
          },
        );

        avatarCounter := avatarCounter + 1;
        return avatarCounter -1;
      };
    };

  };

  public query func getAvatar(id : Nat) : async Result.Result<Avatar, Text> {
    let currAvatar : Avatar = avatarBufferStore.get(id);
    return #ok(currAvatar);
  };

  public query func getAvatarImage(avatarId : Nat) : async Result.Result<AvatarImage, Text> {
    let _avatarImageMap = Buffer.mapFilter<AvatarImage, AvatarImage>(
      avatarImageBufferStore,
      func(value : AvatarImage) {
        if (value.id == avatarId) { return ?value } else { return null };
      },
    );

    var avatarImage = _avatarImageMap.vals().next();
    //Debug.print("getAvatarImage " # Nat.toText(avatarId));

    switch avatarImage {
      case null {
        Debug.print("avatarImage null");
        return #err("Avatar doesn´t exists");
      };
      case (?avatarImage) {
        return #ok(avatarImage);
      };
    };
  };

  public query func updateAvatar(
    id : Nat,
    owner : Principal,
    name : Text,
    ownerName : Text,
    description : Text,
    votes : Nat,
  ) : async Result.Result<Avatar, Text> {
    if (id >= avatarBufferStore.size()) {
      return #err("Avatar doesn´t exists");
    };
    let currAvatar : Avatar = avatarBufferStore.get(id);
    avatarBufferStore.put(
      id,
      {
        id = id;
        owner = owner;
        name = name;
        ownerName = ownerName;
        description = description;
        votes = votes;
        subAvatar = currAvatar.subAvatar;
      },
    );
    return #ok(currAvatar);
  };

  public shared query ({ caller }) func getAllAvatars() : async [Avatar] {
    Debug.print("Caller: " # Principal.toText(caller) # " getAllAvatars");
    return Iter.toArray(avatarBufferStore.vals());
  };

  public shared query ({ caller }) func getAllAvatarImages() : async [AvatarImage] {
    Debug.print("Caller: " # Principal.toText(caller) # " getAllAvatarImages");
    return Iter.toArray(avatarImageBufferStore.vals());
  };

  public shared ({ caller }) func deleteAllAvatar() : async () {
    avatarBufferStore.clear();
  };

  public shared ({ caller }) func deleteAllAvatarImages() : async () {
    avatarImageBufferStore.clear();
  };

  public shared query ({ caller }) func getArtistAvatars(ownerId : Principal) : async [Avatar] {
    Debug.print("Caller: " # Principal.toText(caller) # " getArtistAvatars");
    let _avatarMap = Buffer.mapFilter<Avatar, Avatar>(
      avatarBufferStore,
      func(value : Avatar) {
        if (value.owner == ownerId) { ?value } else { null };
      },
    );
    return Iter.toArray(_avatarMap.vals());
  };

  public shared ({ caller }) func getMyAvatars() : async [Avatar] {
    Debug.print("Caller: " # Principal.toText(caller) # " getMyAvatars");
    return await getArtistAvatars(caller);
  };

  public shared ({ caller }) func avatarUpdate(avatar : Avatar) : async Result.Result<Bool, Text> {
    Debug.print("Caller: " # Principal.toText(caller) # " avatarUpdate");
    let currAvatar : Avatar = avatarBufferStore.get(avatar.id);

    if (avatar.owner == caller) {
      avatarBufferStore.put(
        avatar.id,
        {
          id = avatar.id;
          owner = caller;
          ownerName = currAvatar.ownerName;
          name = avatar.name;
          description = avatar.description;
          subAvatar = currAvatar.subAvatar;
          votes = currAvatar.votes;
        },
      );
      return #ok(true);
    } else {
      return #err("Unauthorized");
    };
  };

  public shared /*({ caller })*/ func avatarDelete(caller : Principal, avatarId : Nat) : async Result.Result<Bool, Text> {
    Debug.print("Caller: " # Principal.toText(caller) # " avatarDelete");

    try {
      let _avatarMap = Buffer.mapFilter<Avatar, Avatar>(
        avatarBufferStore,
        func(value : Avatar) {
          if (value.id == avatarId) { ?value } else { null };
        },
      );

      var currAvatar = _avatarMap.vals().next();

      switch currAvatar {
        case null {
          Debug.print("Avatar a borrar no encontrado");
          return #err("Avatar to delete not found " # Nat.toText(avatarId));
        };
        case (?currAvatar) {
          Debug.print("Avatar a borrar encontrado " # Nat.toText(currAvatar.id) # " - " # Principal.toText(currAvatar.owner));
          if (currAvatar.owner == caller) {
            Debug.print("Avatar a borrar encontrado autorizado");
            var index = Buffer.indexOf<Avatar>(
              currAvatar,
              avatarBufferStore,
              func(a : Avatar, b : Avatar) : Bool {
                return a.id == b.id;
              },
            );

            switch (index) {
              case null {
                Debug.print("Avatar a borrar indice no encontrado");
              };
              case (?index) {
                Debug.print("Avatar a borrar indice:: " # Nat.toText(index));
                ignore avatarBufferStore.remove(index);
              };
            };

            let _avatarImageMap = Buffer.mapFilter<AvatarImage, AvatarImage>(
              avatarImageBufferStore,
              func(value : AvatarImage) {
                if (value.id == avatarId) { ?value } else { null };
              },
            );

            var currAvatarImage : ?AvatarImage = _avatarImageMap.vals().next();

            switch (currAvatarImage) {
              case null {
                Debug.print("AvatarImage a borrar no encontrado");
                return #ok(true);
              };
              case (?currAvatarImage) {
                Debug.print("AvatarImage a borrar indice:: " # Principal.toText(currAvatarImage.owner));
                index := Buffer.indexOf<AvatarImage>(
                  currAvatarImage,
                  avatarImageBufferStore,
                  func(a : AvatarImage, b : AvatarImage) : Bool {
                    return a.id == b.id;
                  },
                );
                switch (index) {
                  case null {
                    Debug.print("AvatarImage a borrar indice no encontrado");
                    return #ok(true);
                  };
                  case (?index) {
                    Debug.print("AvatarImage a borrar indice:: " # Nat.toText(index));
                    ignore avatarImageBufferStore.remove(index);
                    return #ok(true);
                  };
                };
              };
            };
          } else {
            return #err("Unauthorized");
          };
        };
      };
    } catch e {
      Debug.print("Error:: " # Error.message(e));
      #err("Error:: " # Error.message(e));
    };
  };

  // ==============================================================
  // MyProfile
  // ==============================================================
  type StudentProfile = Type.StudentProfile;
  stable var studentProfileEntries : [(Principal, StudentProfile)] = [];
  let studentProfileIter = studentProfileEntries.vals();

  let studentProfileHashMapStore : HashMap.HashMap<Principal, StudentProfile> = HashMap.fromIter<Principal, StudentProfile>(studentProfileIter, 10, Principal.equal, Principal.hash);

  public query /*({ caller })*/ func whoami(caller : Principal) : async Result.Result<StudentProfile, Text> {
    Debug.print("Caller: " # Principal.toText(caller) # " whoami");
    let student : ?StudentProfile = studentProfileHashMapStore.get(caller);
    switch (student) {
      case null {
        #err("Student does not exists");
      };
      case (?student) {
        #ok(student);
      };
    };
  };

  public query func getUserProfile(principal : Principal) : async Result.Result<StudentProfile, Text> {
    Debug.print("getUserProfile: " # Principal.toText(principal));
    let student : ?StudentProfile = studentProfileHashMapStore.get(principal);
    switch (student) {
      case null {
        #err("Student does not exists");
      };
      case (?student) {
        #ok(student);
      };
    };
  };

  public query func getUserProfileByNickName(nickname : Text) : async Result.Result<StudentProfile, Text> {
    Debug.print("getUserProfileByNickname: " # nickname);
    let upEntries : [(Principal, StudentProfile)] = Iter.toArray(studentProfileHashMapStore.entries());

    let _nickname = Text.map(nickname, Prim.charToLower);
    let byNickList = Array.mapFilter<(Principal, StudentProfile), (Principal, StudentProfile)>(
      upEntries,
      func(principal : Principal, studentProfile : StudentProfile) {
        if (studentProfile.nickname == _nickname) {
          ?(principal, studentProfile);
        } else { null };
      },
    );

    if (byNickList.size() == 1) {
      for ((key, value) in Iter.fromArray(byNickList)) {
        return #ok(value);
      };
      return #err("Account with nickname not found");
    } else {
      return #err("Account with nickname not found");
    };
  };

  public shared /*({ caller })*/ func addMyProfile(caller : Principal, profile : StudentProfile) : async Result.Result<Nat, Text> {
    Debug.print("addMyProfile Caller: " # Principal.toText(caller) # " addMyProfile");
    let student : ?StudentProfile = studentProfileHashMapStore.get(caller);

    Debug.print("addMyProfile Caller: addMyProfile student");

    let _nickname = Text.map(profile.nickname, Prim.charToLower);

    let upEntries : [(Principal, StudentProfile)] = Iter.toArray(studentProfileHashMapStore.entries());
    let nicknameRepeated = Array.mapFilter<(Principal, StudentProfile), (Principal, StudentProfile)>(
      upEntries,
      func(principal : Principal, studentProfile : StudentProfile) {
        if (studentProfile.nickname == _nickname) {
          ?(principal, studentProfile);
        } else { null };
      },
    );

    if (nicknameRepeated.size() > 0) {
      for ((key, value) in Iter.fromArray(nicknameRepeated)) {
        if (value.owner != caller) {
          return #err("Nickname already exists, please change it");
        };
      };
    };

    let innerProfile : StudentProfile = {
      owner = caller;
      nickname = _nickname;
      name = profile.name;
      avatar = profile.avatar;
      graduate = profile.graduate;
      subStudentProfile = null;
    };

    Debug.print("addMyProfile Caller: addMyProfile new object");

    switch (student) {
      case null {
        Debug.print("addMyProfile Caller: addMyProfile student switch null");
        studentProfileHashMapStore.put(
          caller,
          innerProfile,
        );
        Debug.print("addMyProfile Caller: addMyProfile put");

        let account : Account = {
          owner = caller;
          subaccount = null;
        };
        Debug.print("addMyProfile Caller: addMyProfile new account");

        // Check if studend haves MotoCoin Account
        // if account doesn`t exits, then it is created
        let balance : ?Nat = ledgerTrieMap.get(account);
        Debug.print("addMyProfile Caller: addMyProfile bakance  ");
        switch (balance) {
          case (null) {
            Debug.print("addMyProfile Caller: addMyProfile balance null");
            ledgerTrieMap.put(account, ACCOUNT_BALANCE_BONUS);
            Debug.print("addMyProfile Caller: addMyProfile pull null");
            return #ok(0); // 0: New account
          };
          case (?balance) {
            Debug.print("addMyProfile Caller: addMyProfile balance exists, no more todo");
            Debug.print("addMyProfile Caller: addMyProfile account updated");
            return #ok(1); // 1: Account updated and set new balance
          };
        };
      };
      case (?student) {
        Debug.print("addMyProfile Caller: addMyProfile student switch no null");
        ignore studentProfileHashMapStore.replace(caller, innerProfile);
        Debug.print("addMyProfile Caller: addMyProfile replace");

        let account : Account = {
          owner = caller;
          subaccount = null;
        };
        Debug.print("addMyProfile Caller: addMyProfile new account");

        // Check if studend haves MotoCoin Account
        // if account doesn`t exits, then it is created
        let balance : ?Nat = ledgerTrieMap.get(account);
        Debug.print("addMyProfile Caller: addMyProfile get balance");
        switch (balance) {
          case (null) {
            Debug.print("addMyProfile Caller: addMyProfile balance null");
            ledgerTrieMap.put(account, ACCOUNT_BALANCE_BONUS);
            Debug.print("addMyProfile Caller: addMyProfile put null");
            return #ok(0); // 0: New account
          };
          case (?balance) {
            Debug.print("addMyProfile Caller: addMyProfile balance exist no more todol");
            return #ok(1); // 1: Account updated and set new balance
          };
        };
        Debug.print("addMyProfile Caller: addMyProfile account updated");
        return #ok(2); // 2: Account updated
      };
    };
  };

  public shared query ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    Debug.print("Caller: " # Principal.toText(caller) # " seeAProfile");
    let student : ?StudentProfile = studentProfileHashMapStore.get(p);
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
    Debug.print("Caller: " # Principal.toText(caller) # " updateMyProfile");
    let student : ?StudentProfile = studentProfileHashMapStore.get(caller);
    switch (student) {
      case null {
        #err("Student does not exists");
      };
      case (?student) {
        ignore studentProfileHashMapStore.replace(caller, student);
        #ok();
      };
    };
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
    Debug.print("Caller: " # Principal.toText(caller) # " deleteMyProfile");
    let student : ?StudentProfile = studentProfileHashMapStore.get(caller);
    switch (student) {
      case null {
        #err("Student does not exists");
      };
      case (?student) {
        studentProfileHashMapStore.delete(caller);
        #ok();
      };
    };
  };

  public shared ({ caller }) func getAllStudentProfiles() : async [StudentProfile] {
    Debug.print("Caller: " # Principal.toText(caller) # "");
    return Iter.toArray(studentProfileHashMapStore.vals());
  };

  // ==============================================================
  // MotoCoin
  // ==============================================================
  let ACCOUNT_BALANCE_BONUS : Nat = 1000;
  let LIKE_MOTOCOIN_VALUE : Nat = 1;
  public type Account = Account.Account;

  stable var ledgerEntries : [(Account, Nat)] = [];
  let ledgerIter = ledgerEntries.vals();

  var ledgerTrieMap : TrieMap.TrieMap<Account, Nat> = TrieMap.fromEntries<Account, Nat>(ledgerIter, Account.accountsEqual, Account.accountsHash);

  // Returns the name of the token
  public query func name() : async Text {
    return "Graffiti";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public query func totalSupply() : async Nat {
    var total = 0;
    for (accountBalance : Nat in ledgerTrieMap.vals()) {
      total += accountBalance;
    };
    return total;
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    let balance = ledgerTrieMap.get(account);
    switch (balance) {
      case null {
        return 0;
      };
      case (?balance) {
        return balance;
      };
    };
  };

  public query /*({ caller })*/ func myBalance(caller : Principal) : async Result.Result<Nat, Text> {
    Debug.print("Caller: " # Principal.toText(caller) # " myBalance");
    let account : Account = {
      owner = caller;
      subaccount = null;
    };
    let balance = ledgerTrieMap.get(account);
    switch (balance) {
      case null {
        return #err("Account doesn`t exists");
      };
      case (?balance) {
        return #ok(balance);
      };
    };
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    Debug.print("Caller: " # Principal.toText(caller) # " transfer");
    let balanceFrom = ledgerTrieMap.get(from);
    let balanceTo = ledgerTrieMap.get(to);

    switch (balanceFrom) {
      case null {
        return #err("from account balance doesn´t exists");
      };
      case (?balanceFrom) {
        switch (balanceTo) {
          case null {
            return #err("to account balance doesn´t exists");
          };
          case (?balanceTo) {
            ledgerTrieMap.put(from, balanceFrom - amount);
            ledgerTrieMap.put(to, balanceTo - amount);
            return #ok;
          };
        };
      };
    };
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
      mbcPrincipalsHashMap.put(mbcStudents[studentId], mbcStudents[studentId]);

      let account : Account = {
        owner = mbcStudents[studentId];
        subaccount = null;
        balance = ACCOUNT_BALANCE_BONUS;
      };
      ledgerTrieMap.put(account, ACCOUNT_BALANCE_BONUS);
      Debug.print("Principal " # Nat.toText(studentId));
    };
    Debug.print("mbcPrincipalsHashMap Generated");

    //return Iter.toArray(ledgerTrieMap.keys());
    #ok();
  };

  public shared func getAllLedgerAccountsKeys() : async [Account] {
    return Iter.toArray(ledgerTrieMap.keys());
  };

  public shared func getAllLedgerAccountsValues() : async [Nat] {
    return Iter.toArray(ledgerTrieMap.vals());
  };

  // ==============================================================
  // Voting
  // ==============================================================
  let VOTE_PRICE : Nat = 1;
  type Vote = Type.Vote;

  stable var votingEntries : [(
    Vote // Vote with Voter
  )] = [];
  let votingIter = votingEntries.vals();

  // Store individual votes for each avatar
  let votingBufferStore : Buffer.Buffer<Vote> = Buffer.fromIter<Vote>(votingIter);

  func updateTotalAvatarVote(avatar : Avatar, _votes : Int) : async () {
    Debug.print("Replicating total votes " # Nat.toText(avatar.id) # " - " # Int.toText(_votes));

    let avatarVote = avatarVoteStore.get(avatar.id);
    var totalVotes = 0;
    switch (avatarVote) {
      case (null) {};
      case (?avatarVote) {
        totalVotes := avatarVote.votes;
      };
    };

    Debug.print("Current total votes " # Nat.toText(totalVotes));

    avatarVoteStore.put(
      avatar.id,
      {
        avatarId = avatar.id;
        votes = Int.abs(totalVotes + _votes);
      },
    );
    Debug.print("AvatarVoteStore.put finished ");

    Debug.print("Updating total votes: " # Nat.toText(avatar.id) # " - " # Int.toText(totalVotes + _votes));

    let _avatarIndex = Buffer.indexOf<Avatar>(
      avatar,
      avatarBufferStore,
      func(a : Avatar, b : Avatar) : Bool {
        return a.id == b.id;
      },
    );

    switch (_avatarIndex) {
      case (null) {};
      case (?_avatarIndex) {
        Debug.print("Updating avatar: " # Nat.toText(avatar.id) # " in index " # Int.toText(_avatarIndex));
        avatarBufferStore.put(
          _avatarIndex,
          {
            id = avatar.id;
            name = avatar.name;
            owner = avatar.owner;
            ownerName = avatar.ownerName;
            description = avatar.description;
            votes = Int.abs(totalVotes + _votes);
            subAvatar = avatar.subAvatar;
          },
        );
        Debug.print("Updating total votes finished");
      };
    };
  };

  // Vote: Set Vote for avatar
  // Return voter balance
  // balance >= 0  --> vote success
  // balance = -1  -->insufficient MotoCoins
  public shared /*({ caller })*/ func vote(caller : Principal, _avatarId : Nat, setVote : Bool) : async Result.Result<Nat, Text> {
    Debug.print("Caller: " # Principal.toText(caller) # " vote");

    let _avatarMap = Buffer.mapFilter<Avatar, Avatar>(
      avatarBufferStore,
      func(value : Avatar) {
        if (value.id == _avatarId) { return ?value } else { return null };
      },
    );

    var _avatarOp = _avatarMap.vals().next();
    var avatar : Avatar = {
      id = 0;
      name = "";
      description = "";
      owner = caller;
      ownerName = "";
      subAvatar = null;
      votes = 0;
    };

    switch _avatarOp {
      case null {};
      case (?_avatarOp) {
        avatar := _avatarOp;
      };
    };

    var mbcAccountMap = TrieMap.mapFilter<Account, Nat, Nat>(
      ledgerTrieMap,
      Account.accountsEqual,
      Account.accountsHash,
      func(key : Account, value : Nat) {
        if (key.owner == caller) { ?value } else { null };
      },
    );

    let accounts1 = Iter.toArray(mbcAccountMap.keys());

    var voterAccount : Account = {
      owner = caller;
      subaccount = null;
    };

    if (accounts1.size() == 1) {
      var balance = 0;
      switch (await myBalance(caller)) {
        case (#ok(_val)) {
          Debug.print("Voter account balance: " # Nat.toText(_val));
          balance := _val;
        };
        case (#err(msg)) {
          Debug.print("Your MotoCoin acount have problems, contact support.");
          return #err("Your MotoCoin acount have problems, contact support.");
        };
      };

      if (balance < VOTE_PRICE) {
        Debug.print("You don´t have sufficient Motocoins to vote, You don't have enough funds to vote, but you can earn them by expressing yourself in Life Vibes, do it now!");
        return #err("You don´t have sufficient Motocoins to vote, You don't have enough funds to vote, but you can earn them by expressing yourself in Life Vibes, do it now!");
      };
    } else {
      Debug.print("Account voter doesn´t exists");
      return #err("Account voter doesn´t exists");
    };

    let student : ?StudentProfile = studentProfileHashMapStore.get(caller);

    switch (student) {
      case null {
        Debug.print("Student does not exists");
        return #err("Student does not exists");
      };
      case (?student) {};
    };

    let _vote : ?Vote = await getVoteForAvatarIdAndVoter(caller, _avatarId);
    var voteType : Int = 0;

    switch (_vote) {
      case null {
        Debug.print("Previous vote doesn´t exists");
        if (setVote) {
          Debug.print("Creating vote");
          votingBufferStore.add({
            avatarId = _avatarId;
            voter = caller;
            subVote = null;
          });

          Debug.print("Counting Vote");
          await updateTotalAvatarVote(avatar, 1);
          voteType := 1;
        };
      };

      case (?_vote) {
        Debug.print("Vote already exists");
        let index = Buffer.indexOf<Vote>(_vote, votingBufferStore, Type.voteEqual);
        Debug.print("Search vote index to store");
        switch (index) {
          case null {
            Debug.print("Existent vote index not found, its a contradiction");
          };
          case (?index) {
            Debug.print("Existent vote index founded in " # Nat.toText(index));
            if (setVote) {
              Debug.print("Previous re vote, do not more");

              votingBufferStore.put(index, _vote);

              Debug.print("Updating total votes for avatar");
              let avatarVotes = avatarVoteStore.get(_avatarId);
              switch (avatarVotes) {
                case null {
                  Debug.print("Vote doesn`t exists in avatarVoteStore");
                  await updateTotalAvatarVote(avatar, 1);
                  voteType := 1;
                };
                case (?avatarVotes) {
                  Debug.print("Vote exists in avatarVoteStore");
                  Debug.print("New account votes " # Nat.toText(avatarVotes.votes + 1));
                  await updateTotalAvatarVote(avatar, 0);
                  voteType := 0;
                };
              };
            } else {
              Debug.print("Deleting vote");
              ignore votingBufferStore.remove(index);

              Debug.print("Discouting vote");
              let avatarVotes = avatarVoteStore.get(_avatarId);
              switch (avatarVotes) {
                case null {
                  Debug.print("Total for count votes not found. its bizzar");
                };
                case (?avatarVotes) {
                  var _votes = 0;
                  Debug.print("New account votes 0");
                  await updateTotalAvatarVote(avatar, -1);
                  voteType := -1;
                };
              };
            };
          };
        };
      };
    };
    Debug.print("Transfer founds from vote |-> " # Principal.toText(caller));

    Debug.print("Voter account set " # Nat.toText(accounts1.size()));

    Debug.print("Getting avatar " # Nat.toText(_avatarId));
    let avatars = Buffer.mapFilter<Avatar, Avatar>(
      avatarBufferStore,
      func(value : Avatar) {
        if (value.id == _avatarId) { ?value } else { null };
      },
    );
    let avatarArr = Iter.toArray(avatars.vals());

    Debug.print("avatarArr set " # Nat.toText(avatarArr.size()));

    if (avatarArr.size() > 0) {
      let avatar = avatarArr[0];
      Debug.print("Avatar " # avatar.ownerName # " - " # Principal.toText(avatar.owner));

      mbcAccountMap := TrieMap.mapFilter<Account, Nat, Nat>(
        ledgerTrieMap,
        Account.accountsEqual,
        Account.accountsHash,
        func(key : Account, value : Nat) {
          if (key.owner == avatar.owner) { ?value } else { null };
        },
      );
      var accounts2 = Iter.toArray(mbcAccountMap.keys());

      Debug.print("avatar owner acount set " # Nat.toText(accounts2.size()));

      if (accounts1.size() > 0 and accounts2.size() > 0) {
        let voterAccount : Account = accounts1[0];
        let avatarOwnerAccount : Account = accounts2[0];

        Debug.print(
          "accounts "
          # Principal.toText(voterAccount.owner)
          # " - "
          # Principal.toText(avatarOwnerAccount.owner)
        );

        let balanceFrom = ledgerTrieMap.get(voterAccount);
        let balanceTo = ledgerTrieMap.get(avatarOwnerAccount);

        switch (balanceFrom) {
          case null {
            return #err("from account balance doesn´t exists");
          };
          case (?balanceFrom) {
            if (voteType == 0) {
              return #ok(balanceFrom);
            } else {
              switch (balanceTo) {
                case null {
                  return #err("to account balance doesn´t exists");
                };
                case (?balanceTo) {
                  if (setVote) {
                    ledgerTrieMap.put(voterAccount, balanceFrom - LIKE_MOTOCOIN_VALUE);
                    ledgerTrieMap.put(avatarOwnerAccount, balanceTo + LIKE_MOTOCOIN_VALUE);
                    return #ok(balanceFrom - LIKE_MOTOCOIN_VALUE);
                  } else {
                    ledgerTrieMap.put(voterAccount, balanceFrom + LIKE_MOTOCOIN_VALUE);
                    ledgerTrieMap.put(avatarOwnerAccount, balanceTo - LIKE_MOTOCOIN_VALUE);
                    return #ok(balanceFrom + LIKE_MOTOCOIN_VALUE);
                  };
                };
              };
            };
          };
        };
      } else {
        if (accounts1.size() == 0) {
          #err("Your MotoCoin Account doesn`t exists, please apudate your profile info to fix it ");
        } else if (accounts2.size() == 0) {
          #err("The MotoCoin Account of Graffiti Creator haves problems: ");
        } else {
          #err("any accounts doesn´t exists [ " # Nat.toText(avatarArr.size()) # " - " # Nat.toText(accounts2.size()) # " ]");
        };
      };
    } else {
      #err("avatar doesn't exists");
    };

  };

  func getVotesForAvatar(avatarId : Int) : async [Vote] {
    let votes = Buffer.mapFilter<Vote, Vote>(
      votingBufferStore,
      func(element : Vote) {
        if (element.avatarId == avatarId) {
          ?element;
        } else {
          null;
        };
      },
    );
    return Buffer.toArray(votes);
  };

  public shared func getAllVotes() : async [Vote] {
    return Buffer.toArray(votingBufferStore);
  };

  public shared func getAllAvatarVotes() : async [AvatarVotes] {
    return Iter.toArray(avatarVoteStore.vals());
  };

  public shared func getAllAvatarsForStudent(nickname : Text) : async [Avatar] {
    let studentProfileResult = await getUserProfileByNickName(nickname);

    switch (studentProfileResult) {
      case (#ok(profile)) {
        let _avatarMap = Buffer.mapFilter<Avatar, Avatar>(
          avatarBufferStore,
          func(value : Avatar) {
            if (value.owner == profile.owner) { return ?value } else {
              return null;
            };
          },
        );
        return Iter.toArray(_avatarMap.vals());
      };
      case (#err(msg)) {
        return [];
      };
    };
  };

  public query func getVoteForAvatarIdAndVoter(voter : Principal, avatarId : Int) : async ?Vote {
    let votes = Buffer.mapFilter<Vote, Vote>(
      votingBufferStore, // first parameter
      func(element : Vote) {
        if (element.voter == voter and element.avatarId == avatarId) {
          ?element;
        } else {
          null;
        };
      },
    );
    if (votes.size() > 0) {
      let vote : Vote = Iter.toArray(votes.vals())[0];
      return ?vote;
    } else {
      return null;
    };
  };

  /*public query func getVoteForAvatarIdAndVoter(voter : Principal, avatarId : Int): async Result.Result<Vote, Text> {
    let _vote : ?Vote = await _getVoteForAvatarIdAndVoter(voter, _avatarId);
    return #ok(_vote);
  };*/

  type AvatarVotes = {
    avatarId : Nat;
    votes : Nat;
  };
  stable var avatarVoteCounter : Nat = 0;
  stable var avatarVoteEntries : [(Nat, AvatarVotes)] = [];
  let avatarVoteIter = avatarVoteEntries.vals();

  // Store total votes for each avatar
  let avatarVoteStore : HashMap.HashMap<Nat, AvatarVotes> = HashMap.fromIter<Nat, AvatarVotes>(avatarVoteIter, 10, Nat.equal, Hash.hash);

  public query func getRanking() : async [Avatar] {
    let arrAvatarVotesVals = Iter.toArray(avatarBufferStore.vals());

    let rankingWall = Array.sort(
      arrAvatarVotesVals,
      func(a : Avatar, b : Avatar) : { #less; #equal; #greater } {
        if (a.votes > b.votes) {
          #less; // Instead of #greater
        } else if (a.votes < b.votes) {
          #greater; // Instead of #less
        } else {
          #equal;
        };
      },
    );
    if (rankingWall.size() > 10) {
      return Array.subArray(rankingWall, 0, 10);
    } else {
      return rankingWall;
    };
  };

  system func preupgrade() {
    avatarEntries := Iter.toArray(avatarBufferStore.vals());
    avatarImageEntries := Iter.toArray(avatarImageBufferStore.vals());
    studentProfileEntries := Iter.toArray(studentProfileHashMapStore.entries());

    ledgerEntries := Iter.toArray(ledgerTrieMap.entries());
    votingEntries := Iter.toArray(votingBufferStore.vals());
    avatarVoteEntries := Iter.toArray(avatarVoteStore.entries());
  };

  system func postupgrade() {
    avatarEntries := [];
    avatarImageEntries := [];
    studentProfileEntries := [];
    ledgerEntries := [];
    votingEntries := [];
    avatarVoteEntries := [];
  };

  public func getMBCStudentPrincipals() : async Principal {
    let mbcStudentsCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
    };

    let mbcStudents : [Principal] = await mbcStudentsCanister.getAllStudentsPrincipal();

    return mbcStudents[0];
  };

};
