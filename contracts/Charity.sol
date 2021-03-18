pragma solidity ^0.5.0;

contract Charity {

  enum CharityStatus {
	  UNVERIFIED, VERIFIED, REJECTED
  }

  enum CampaignStatus {
	  ONGOING, ENDED
  }

  struct charity {
	  address charityOwner;
    bytes32 charityName;
    bytes32 charityAddress;
    bytes32 contactNumber;
    bytes32 description;
    bytes32 pictureURL;
    CharityStatus charityStatus;
  }

  struct campaign {
    uint charityId;
    bytes32 campaignName;
    bytes32 description;
    bytes32 pictureURL;
    uint targetDonation;
    uint currentDonation;
    uint noOfDonors;
    uint startDate;
    uint endDate;
    CampaignStatus campaignStatus;
  }

  address contractOwner;
  //uint[] charitiesPendingVerification;
  mapping(address => bool) isVerifiedCharity;
  mapping(uint => charity) charities;
  mapping(address => uint) charityAddressMap;
  uint noOfCharities = 0;

  //uint[] ongoingCampaigns;
  mapping(uint => bool) isOngoingCampaign;
  mapping(uint => campaign) campaigns;
  uint noOfCampaigns = 0;

  event charityRegistered (uint charityId);
  event charityVerified (uint charityId);
  event charityRejected (uint charityId);
  event charityRevoked (uint charityId);
  event campaignCreated(uint charityId, uint campaignId);
  event campaignEnded(uint campaignId);


  modifier onlyOwner(address caller) {
    require(caller == contractOwner, "Caller is not contract owner");
    _;
  }


  // This will be the modifier that checks whether the function call is done by the Charity itself.
  modifier onlyVerifiedCharity(address caller) {
    require(isVerifiedCharity[caller], "Caller is not a valid charity");
    _;
  }

  function registerCharity(bytes32 charityName, bytes32 charityAddress, bytes32 contactNumber, bytes32 description, bytes32 pictureURL) public returns (uint charityId) {
    require(charityName != "Charity name cannot be empty");
    require(description != "Description cannot be empty");
    require(pictureURL != "Picture URL cannot be empty");

    charityId = noOfCharities++;
    charity memory newCharity = charity(msg.sender, charityName, charityAddress, contactNumber, description, pictureURL, CharityStatus.UNVERIFIED);
    charities[charityId] = newCharity;
    charityAddressMap[msg.sender] = charityId;
    isVerifiedCharity[charities[charityId].charityOwner] = false;
    emit charityRegistered(charityId);
    // charitiesPendingVerification.push(charityId);
    return charityId;
  }

  function verifyCharity(uint charityId) public onlyOwner(msg.sender) {
    require(msg.sender == contractOwner, "Caller is not contract owner");
    require(charityId < noOfCharities, "Invalid charity id");
    require(charities[charityId].charityStatus == CharityStatus.UNVERIFIED, "Charity has been verified or rejected");
    require(isVerifiedCharity[charities[charityId].charityOwner] == false, "Charity has been verified");

    charities[charityId].charityStatus = CharityStatus.VERIFIED;
    isVerifiedCharity[charities[charityId].charityOwner] = true;
    emit charityVerified(charityId);
    // remove charity from charitiesPendingVerification[]
  }

  function rejectCharity(uint charityId) public onlyOwner(msg.sender) {
    require(msg.sender == contractOwner, "Caller is not contract owner");
    require(charityId < noOfCharities, "Invalid charity id");
    require(charities[charityId].charityStatus == CharityStatus.UNVERIFIED, "Charity has been verified or rejected");
    require(isVerifiedCharity[charities[charityId].charityOwner] == false, "Charity has been verified");

    charities[charityId].charityStatus = CharityStatus.REJECTED;
    emit charityRejected(charityId);
    // remove charity from charitiesPendingVerification[]
  }

  function revokeCharity(uint charityId) public onlyOwner(msg.sender) {
    require(msg.sender == contractOwner, "Caller is not contract owner");
    require(charityId < noOfCharities, "Invalid charity id");
    require(charities[charityId].charityStatus == CharityStatus.VERIFIED, "Charity is not a verified charity");
    require(isVerifiedCharity[charities[charityId].charityOwner] == true, "Charity has been verified");

    charities[charityId].charityStatus = CharityStatus.REJECTED;
    emit charityRevoked(charityId);
  }

  /*
  * This will be the function that charities call to create a campaign.
  * Parameters of this function will include uint targetDonation (of the campaign), uint startDate (of the campaign), uint endDate (of the campaign)
  */
  function createCampaign(bytes32 campaignName, bytes32 description, bytes32 pictureURL, uint targetDonation, uint startDate, uint endDate) public onlyVerifiedCharity(msg.sender) returns (uint campaignId) {
    require(campaignName != "Charity name cannot be empty");
    require(description != "Description cannot be empty");
    require(pictureURL != "Picture URL cannot be empty");
    require(targetDonation > 0, "Target donation must be larger than 0");
    require(startDate < endDate, "Start date must be earlier than end date");

    campaignId = noOfCampaigns++;
    uint charityId = charityAddressMap[msg.sender];
    campaign memory newCampaign = campaign(charityId, campaignName, description, pictureURL, targetDonation, 0, 0, startDate, endDate, CampaignStatus.ONGOING);
    campaigns[campaignId] = newCampaign;
    // ongoingCampaigns.push(campaignId);
    isOngoingCampaign[campaignId] = true;
    emit campaignCreated(charityId, campaignId);
    return campaignId;
  }

  /*
  *
  * This will be the function that charities call to end an ongoing campaign.
  * Parameters of this function will include uint campaignId
  */
  function endCampaign(uint campaignId) public onlyVerifiedCharity(msg.sender) onlyOwner(msg.sender) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    require(isOngoingCampaign[campaignId], "Campaign is not ongoing");
    require(msg.sender == charities[campaigns[campaignId].charityId].charityOwner, "Caller is not owner of charity");

    campaigns[campaignId].campaignStatus = CampaignStatus.ENDED;
    isOngoingCampaign[campaignId] = false;
    emit campaignEnded(campaignId);
    // remove campaign from ongoingCampaigns[]
  }

  /*
  * This will be the getter function that everyone can call to check the charity address.
  * Parameters of this function will include uint charityId
  */
  function getCharityOwner(uint charityId) public view returns (address) {
    require(charityId < noOfCharities, "Invalid charity id");
    return charities[charityId].charityOwner;
  }

  /*
  * This will be the getter function that everyone can call to check the charity name.
  * Parameters of this function will include uint charityId
  */
  function getCharityName(uint charityId) public view returns (bytes32) {
    require(charityId < noOfCharities, "Invalid charity id");
    return charities[charityId].charityName;
  }

  /*
  * This will be the getter function that everyone can call to check the charity pictureURL.
  * Parameters of this function will include uint charityId
  */
  function getCharityPictureURL(uint charityId) public view returns (bytes32) {
    require(charityId < noOfCharities, "Invalid charity id");
    return charities[charityId].pictureURL;
  }

  /*
  * This will be the getter function that everyone can call to check the charity description.
  * Parameters of this function will include uint charityId
  */
  function getCharityDescription(uint charityId) public view returns (bytes32) {
    require(charityId < noOfCharities, "Invalid charity id");
    return charities[charityId].description;
  }

  /*
  * This will be the getter function that everyone can call to check the charity status.
  * Parameters of this function will include uint charityId
  */
  function getCharityStatus(uint charityId) public view returns (CharityStatus) {
    require(charityId < noOfCharities, "Invalid charity id");
    return charities[charityId].charityStatus;
  }

  /*
  * This will be the getter function that everyone can call to check the campaign's charityId.
  * Parameters of this function will include uint campaignId
  */
  function getCampaignCharity(uint campaignId) public view returns (uint) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    return campaigns[campaignId].charityId;
  }

  /*
  * This will be the getter function that everyone can call to check the campaign name.
  * Parameters of this function will include uint campaignId
  */
  function getCampaignName(uint campaignId) public view returns (bytes32) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    return campaigns[campaignId].campaignName;
  }

  /*
  * This will be the getter function that everyone can call to check the campaign description.
  * Parameters of this function will include uint campaignId
  */
  function getCampaignDescription(uint campaignId) public view returns (bytes32) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    return campaigns[campaignId].description;
  }

  /*
  * This will be the getter function that everyone can call to check the campaign pictureURL.
  * Parameters of this function will include uint campaignId
  */
  function getCampaignPictureURL(uint campaignId) public view returns (bytes32) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    return campaigns[campaignId].pictureURL;
  }

  /*
  * This will be the getter function that everyone can call to check the campaign targetDonation.
  * Parameters of this function will include uint campaignId
  */
  function getCampaignTargetDonation(uint campaignId) public view returns (uint) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    return campaigns[campaignId].targetDonation;
  }

  /*
  * This will be the getter function that everyone can call to check the campaign currentDonation.
  * Parameters of this function will include uint campaignId
  */
  function getCampaignCurrentDonation(uint campaignId) public view returns (uint) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    return campaigns[campaignId].currentDonation;
  }

  /*
  * This will be the getter function that everyone can call to check the campaign noOfDonors.
  * Parameters of this function will include uint campaignId
  */
  function getCampaignNoOfDonors(uint campaignId) public view returns (uint) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    return campaigns[campaignId].noOfDonors;
  }

  /*
  * This will be the getter function that everyone can call to check the campaign startDate.
  * Parameters of this function will include uint campaignId
  */
  function getCampaignStartDate(uint campaignId) public view returns (uint) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    return campaigns[campaignId].startDate;
  }

  /*
  * This will be the getter function that everyone can call to check the campaign endDate.
  * Parameters of this function will include uint campaignId
  */
  function getCampaignEndDate(uint campaignId) public view returns (uint) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    return campaigns[campaignId].endDate;
  }

  /*
  * This will be the getter function that everyone can call to check the campaign status.
  * Parameters of this function will include uint campaignId
  */
  function getCampaignStatus(uint campaignId) public view returns (CampaignStatus) {
    require(campaignId < noOfCampaigns, "Invalid campaign id");
    return campaigns[campaignId].campaignStatus;
  }



}