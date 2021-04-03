import React, { useEffect, useState } from "react";
import { makeStyles } from "@material-ui/core/styles";
import Box from "@material-ui/core/Box";
import Tabs from "@material-ui/core/Tabs";
import Tab from "@material-ui/core/Tab";
import Grid from "@material-ui/core/Grid";
import Card from "@material-ui/core/Card";
import CardMedia from "@material-ui/core/CardMedia";
import CircularProgress from "@material-ui/core/CircularProgress";

import HomePageBanner from "../assets/homepagebanner.jpg";
import TabPanel from "../components/TabPanel";
import CampaignCard from "../components/CampaignCard";

const useStyles = makeStyles({
  media: {
    height: 300,
    background: `url(${HomePageBanner})`,
    backgroundSize: "cover",
    color: "white",
  },
});

export default function HomePage({
  web3,
  accounts,
  charityContract,
  donationContract,
  isAuthed,
}) {
  const classes = useStyles();
  const [ongoingCampaigns, setOngoingCampaigns] = useState();
  const [pastCampaigns, setPastCampaigns] = useState();
  const [value, setValue] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  const handleChange = (event, newValue) => {
    setValue(newValue);
  };

  var getCampaign = async (campaignId) => {
    var campaign = {};
    campaign.campaignId = campaignId;
    campaign.campaignName = await charityContract.methods
      .getCampaignName(campaignId)
      .call();
    campaign.campaignName = web3.utils.toUtf8(campaign.campaignName);
    campaign.campaignDescription = await charityContract.methods
      .getCampaignDescription(campaignId)
      .call();
    campaign.campaignDescription = web3.utils.toUtf8(
      campaign.campaignDescription
    );
    campaign.campaignPictureURL = await charityContract.methods
      .getCampaignPictureURL(campaignId)
      .call();
    campaign.campaignPictureURL = web3.utils.toUtf8(
      campaign.campaignPictureURL
    );
    campaign.campaignTargetDonation = await charityContract.methods
      .getCampaignTargetDonation(campaignId)
      .call();
    campaign.campaignTargetDonation = parseInt(
      campaign.campaignTargetDonation,
      10
    );
    campaign.campaignCurrentDonation = await charityContract.methods
      .getCampaignCurrentDonation(campaignId)
      .call();
    campaign.campaignCurrentDonation = parseInt(
      campaign.campaignCurrentDonation,
      10
    );
    campaign.campaignNoOfDonors = await charityContract.methods
      .getCampaignNoOfDonors(campaignId)
      .call();
    campaign.campaignNoOfDonors = parseInt(campaign.campaignNoOfDonors, 10);
    campaign.campaignStartDate = await charityContract.methods
      .getCampaignStartDate(campaignId)
      .call();
    campaign.campaignEndDate = await charityContract.methods
      .getCampaignEndDate(campaignId)
      .call();
    campaign.campaignStatus = await charityContract.methods
      .getCampaignStatus(campaignId)
      .call();
    campaign.charityId = await charityContract.methods
      .getCampaignCharity(campaignId)
      .call();
    campaign.charityId = parseInt(campaign.charityId, 10);
    campaign.charityName = await charityContract.methods
      .getCharityName(campaign.charityId)
      .call();
    campaign.charityName = web3.utils.toUtf8(campaign.charityName);
    campaign.charityPictureURL = await charityContract.methods
      .getCharityPictureURL(campaign.charityId)
      .call();
    campaign.charityPictureURL = web3.utils.toUtf8(campaign.charityPictureURL);
    console.log(campaign);
    return campaign;
  };

  useEffect(async () => {
    const noOfCampaigns = await charityContract.methods
      .getNoOfCampaigns()
      .call();
    let ongoingCampaigns = [];
    let pastCampaigns = [];
    console.log(noOfCampaigns);
    for (let i = 0; i < noOfCampaigns; i++) {
      var campaign = await getCampaign(i);
      if (campaign.campaignStatus === "0") {
        ongoingCampaigns.push(campaign);
      }
      if (campaign.campaignStatus === "1") {
        pastCampaigns.push(campaign);
      }
    }
    setIsLoading(false);
    await setOngoingCampaigns(ongoingCampaigns);
    await setPastCampaigns(pastCampaigns);
  }, []);

  return (
    <Grid
      container
      direction="row"
      justify="center"
      alignItems="center"
      spacing={2}
    >
      <Grid className={classes.media} item xs={12}>
        <Box mt={10} fontWeight="fontWeightBold" fontSize={40}>
          Give the Gift Today!
        </Box>
        <Box fontWeight="fontWeightBold" fontSize={28}>
          Every little bit counts!
        </Box>
      </Grid>
      <Grid item xs={10}>
        <Box textAlign="left" fontWeight="fontWeightBold" fontSize={26}>
          All Campaigns
        </Box>
      </Grid>
      <Grid item xs={10}>
        <Tabs
          value={value}
          indicatorColor="primary"
          textColor="primary"
          onChange={handleChange}
        >
          <Tab label="Ongoing" />
          <Tab label="Past" />
        </Tabs>
        <TabPanel value={value} index={0}>
          <Grid container spacing={3}>
            {isLoading ? (
              <Grid item xs={12}>
                <CircularProgress />
              </Grid>
            ) : (
              ongoingCampaigns &&
              ongoingCampaigns.map((campaign, index) => (
                <Grid key={index} item xs={4}>
                  <CampaignCard data={campaign} />
                </Grid>
              ))
            )}
          </Grid>
        </TabPanel>
        <TabPanel value={value} index={1}>
          <Grid container spacing={3}>
            {isLoading ? (
              <Grid item xs={12}>
                <CircularProgress />
              </Grid>
            ) : (
              pastCampaigns &&
              pastCampaigns.map((campaign, index) => (
                <Grid key={index} item xs={4}>
                  <CampaignCard data={campaign} />
                </Grid>
              ))
            )}
          </Grid>
        </TabPanel>
      </Grid>
    </Grid>
  );
}
