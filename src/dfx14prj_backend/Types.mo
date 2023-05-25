import Result "mo:base/Result";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Option "mo:base/Option";

module {
  public type SubStudentProfile = Blob;

  public type StudentProfile = {
    owner: Principal;
    nickname: Text;
    name : Text;
    avatar: Text;
    graduate : Bool;
    //subStudentProfile: ?SubStudentProfile;
  };


  /*func _getDefaultSubStudentProfile() : SubStudentProfile {
    Blob.fromArrayMut(Array.init(32, 0 : Nat8));
  };
  
  public func studentProfileEqual(lhs : StudentProfile, rhs : StudentProfile) : Bool {
    let lhsSubStudentProfile : SubStudentProfile = Option.get<SubStudentProfile>(lhs.subStudentProfile, _getDefaultSubStudentProfile());
    let rhsSubStudentProfile : SubStudentProfile = Option.get<SubStudentProfile>(rhs.subStudentProfile, _getDefaultSubStudentProfile());
    Principal.equal(lhs.owner, rhs.owner) and Blob.equal(lhsSubStudentProfile, rhsSubStudentProfile);
  };

  public func studentProfileHash(lhs : StudentProfile) : Nat32 {
    let lhsSubStudentProfile : SubStudentProfile = Option.get<SubStudentProfile>(lhs.subStudentProfile, _getDefaultSubStudentProfile());
    let hashSum = Nat.add(Nat32.toNat(Principal.hash(lhs.owner)), Nat32.toNat(Blob.hash(lhsSubStudentProfile)));
    Nat32.fromNat(hashSum % (2 ** 32 - 1));
  };*/

  public type SubAvatar = Blob;

  public type Avatar = {
    id: Nat;
    owner: Principal;
    ownerName: Text;
    name : Text;
    description : Text;
    votes: Nat;
    subAvatar : ?SubAvatar;
  };

  public type AvatarImage = {
    id: Nat;
    owner: Principal;
    image: Text;
    subAvatar : ?SubAvatar;
  };

  func _getDefaultSubAvatar() : SubAvatar {
    Blob.fromArrayMut(Array.init(32, 0 : Nat8));
  };
  
  public func avatarEqual(lhs : Avatar, rhs : Avatar) : Bool {
    let lhsSubaccount : SubAvatar = Option.get<SubAvatar>(lhs.subAvatar, _getDefaultSubAvatar());
    let rhsSubaccount : SubAvatar = Option.get<SubAvatar>(rhs.subAvatar, _getDefaultSubAvatar());
    Principal.equal(lhs.owner, rhs.owner) and Blob.equal(lhsSubaccount, rhsSubaccount);
  };

  public func accountsHash(lhs : Avatar) : Nat32 {
    let lhsSubAvatar : SubAvatar = Option.get<SubAvatar>(lhs.subAvatar, _getDefaultSubAvatar());
    let hashSum = Nat.add(Nat32.toNat(Principal.hash(lhs.owner)), Nat32.toNat(Blob.hash(lhsSubAvatar)));
    Nat32.fromNat(hashSum % (2 ** 32 - 1));
  };

  public func avatarImageEqual(lhs : AvatarImage, rhs : AvatarImage) : Bool {
    let lhsSubaccount : SubAvatar = Option.get<SubAvatar>(lhs.subAvatar, _getDefaultSubAvatar());
    let rhsSubaccount : SubAvatar = Option.get<SubAvatar>(rhs.subAvatar, _getDefaultSubAvatar());
    Principal.equal(lhs.owner, rhs.owner) and Blob.equal(lhsSubaccount, rhsSubaccount);
  };

  public func accountImagesHash(lhs : AvatarImage) : Nat32 {
    let lhsSubAvatar : SubAvatar = Option.get<SubAvatar>(lhs.subAvatar, _getDefaultSubAvatar());
    let hashSum = Nat.add(Nat32.toNat(Principal.hash(lhs.owner)), Nat32.toNat(Blob.hash(lhsSubAvatar)));
    Nat32.fromNat(hashSum % (2 ** 32 - 1));
  };

  public type SubVote = Blob;
  
  public type Vote = {
    avatarId : Nat;
    voter : Principal;
    subVote : ?SubVote;
  };

  func _getDefaultSubVote() : SubAvatar {
    Blob.fromArrayMut(Array.init(32, 0 : Nat8));
  };
  public func voteEqual(lhs : Vote, rhs : Vote) : Bool {
    let lhsSubVote : SubVote = Option.get<SubVote>(lhs.subVote, _getDefaultSubVote());
    let rhsSubVote : SubVote = Option.get<SubVote>(rhs.subVote, _getDefaultSubVote());
    Principal.equal(lhs.voter, rhs.voter) and Blob.equal(lhsSubVote, rhsSubVote);
  };

  public type TestResult = Result.Result<(), TestError>;
  public type TestError = {
    #UnexpectedValue : Text;
    #UnexpectedError : Text;
  };
}