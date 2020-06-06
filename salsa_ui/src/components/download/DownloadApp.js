import React, { Component } from 'react';
import Fade from 'react-reveal/Fade';
import Slide from 'react-reveal/Slide';

import { makeStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';
import IOSIcon from '../../resources/images/app-store-badge.svg';
import AndroidIcon from '../../resources/images/google-play-badge.svg';

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
  paper: {
    padding: theme.spacing(2),
    textAlign: 'center',
    color: theme.palette.text.secondary,
  },
}));

const DownloadApp = () => {

    const classes = useStyles();
    return (
        <Fade>
            <div className="center_wrapper">
                <div className="download_app_description">
                    <Grid
                        container
                        spacing={1}
                        direction="row"
                        justify="center"
                        alignItems="center"
                    >
                        <Grid item xs={6}>
                            <Slide left>
                                <div
                                    style={{
                                        width: "60%",
                                        color: "white",
                                        margin: "auto",
                                    }}
                                >
                                    <a href="https://www.w3schools.com">
                                        <img
                                            src={IOSIcon}
                                            style={{
                                                width: "100%",
                                            }}
                                        />
                                    </a>
                                </div>
                            </Slide>
                        </Grid>
                        <Grid item xs={6}>
                            <Slide right>
                                <div
                                    style={{
                                        width: "60%",
                                        color: "white",
                                        margin: "auto",
                                    }}
                                >
                                    <a href="https://www.w3schools.com">
                                        <img
                                            src={AndroidIcon}
                                            style={{
                                                width: "100%",
                                            }}
                                        />
                                    </a>
                                </div>
                            </Slide>
                        </Grid>
                    </Grid>
                </div>
            </div>
        </Fade>
    );
}

export default DownloadApp;