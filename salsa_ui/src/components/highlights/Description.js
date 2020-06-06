import React, { Component } from 'react';
import Fade from 'react-reveal/Fade';
import Grid from '@material-ui/core/Grid';

const Description = () => {

    return (
        <Fade>
            <div className="center_wrapper">
                <h2>Highlights</h2>
                <div className="highlight_description">
                    <Grid
                        container
                        spacing={1}
                        direction="row"
                        justify="center"
                        alignItems="center"
                    >
                        <Grid item xs={6}>
                            <div
                                style={{
                                    padding: "20px",
                                }}
                            >
                                <p>
                                    Online orders, Group orders, Group shopping become
                                    more and more popular in these days.
                                </p>
                                <p>
                                    Do you have troublesome to track what and where you
                                    ordered from, or who and what ordered from your
                                    store? Did you experience missing orders, orders
                                    without owners as result of lacking good tracking
                                    system?
                                </p>
                                <p>
                                    Heli Together Strong can help you. Above troublesome
                                    will go away.
                                </p>
                            </div>
                        </Grid>
                        <Grid item xs={6}>
                            <div
                                style={{
                                    padding: "20px",
                                }}
                            >
                                <p>
                                    网购， 团购, 代购当今越来越流行了。
                                </p>
                                <p>
                                    头疼的事情也随之而来，不记得买了什么，在哪个店买的；
                                    或者你的顾客是谁，在你店里买了什么？ 你经历过漏单，
                                    订的单货没收到过， 或者顾客走单的？
                                </p>
                                <p>
                                    有了合力这个系统， 头痛的事情就拜拜了。 买的开心，
                                    卖的轻松！ 马上下载！
                                </p>
                            </div>
                        </Grid>
                    </Grid>
                </div>
            </div>
        </Fade>

    );
}

export default Description;