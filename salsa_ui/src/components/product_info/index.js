import React, { Component } from 'react';
import Zoom from 'react-reveal/Zoom';
import Grid from '@material-ui/core/Grid';

import icon_calendar from '../../resources/images/icons/calendar.png';
import icon_location from '../../resources/images/icons/location.png';

import wallet from '../../resources/images/icons/wallet.png';
import banner from '../../resources/images/icons/banner.png';
import family from '../../resources/images/icons/family.png';

const ProductInfo = () => {

    return (
        <div className="bck_black">
            <div className="center_wrapper">
                <div className="vn_wrapper">

                    <Grid
                        container
                        spacing={1}
                        direction="row"
                        justify="center"
                        alignItems="center"
                    >
                    <Grid item xs={4} style={{minWidth: "300px"}}>
                        <div className="vn_item">
                            <div className="vn_outer">
                                <div className="vn_inner">
                                    <div className="vn_icon_square bck_offwhite"></div>
                                    <div
                                        className="vn_icon"
                                        style={{
                                            background: `url(${banner})`
                                        }}>
                                    </div>
                                    <div className="vn_title">
                                        Best Quality
                                    </div>
                                    <div className="vn_desc">
                                        Direct from the source
                                    </div>
                                </div>
                            </div>
                        </div>
                    </Grid>
                    <Grid item xs={4} style={{minWidth: "300px"}}>
                        <div className="vn_item">
                            <div className="vn_outer">
                                <div className="vn_inner">
                                    <div className="vn_icon_square bck_offwhite"></div>
                                    <div
                                        className="vn_icon"
                                        style={{
                                            background: `url(${wallet})`
                                        }}>
                                    </div>
                                    <div className="vn_title">
                                        Lowest Prices
                                    </div>
                                    <div className="vn_desc">
                                        Skip the grocery store
                                    </div>
                                </div>
                            </div>
                        </div>
                    </Grid>

                    <Grid item xs={4} style={{minWidth: "300px"}}>
                        <div className="vn_item">
                            <div className="vn_outer">
                                <div className="vn_inner">
                                    <div className="vn_icon_square bck_offwhite"></div>
                                    <div
                                        className="vn_icon"
                                        style={{
                                            background: `url(${family})`
                                        }}>
                                    </div>
                                    <div className="vn_title">
                                        Trusted Partners
                                    </div>
                                    <div className="vn_desc">
                                        We are your neighbors
                                    </div>
                                </div>
                            </div>
                        </div>
                    </Grid>
                    </Grid>

                    <div></div>
                </div>
            </div>
        </div>
    )
}

export default ProductInfo;