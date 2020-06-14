import React, { Component } from 'react';
import Fade from 'react-reveal/Fade';
import Grid from '@material-ui/core/Grid';
import Card from '@material-ui/core/Card';
import CardActionArea from '@material-ui/core/CardActionArea';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardMedia from '@material-ui/core/CardMedia';
import Button from '@material-ui/core/Button';
import Typography from '@material-ui/core/Typography';

import { scroller } from 'react-scroll';
import pantry from '../../resources/images/pantry.jpg'
import coffee from '../../resources/images/coffee.jpg'

const Description = (props) => {

    const scrollToElement = (element, offset) => {
        scroller.scrollTo(element, {
            duration: 1500,
            delay: 100,
            smooth: true,
            offset: offset
        });
    }

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
                        <Grid item xs={10}>
                            <Card>
                              <CardActionArea>
                                <CardMedia
                                  component="img"
                                  alt="Contemplative Reptile"
                                  height="350"
                                  image={pantry}
                                  title="Contemplative Reptile"
                                />
                                <CardContent>
                                  <Typography gutterBottom variant="h5" component="h2">
                                    Heli
                                  </Typography>
                                  <Typography variant="body2" color="textSecondary" component="span">
                                    <div className="description_text">
                                        <p>
                                            Online orders, Group orders, Group shopping become more and more popular in these days.
                                        </p>
                                        <p>
                                        Do you have troublesome to track what and where you ordered from, or who and what ordered from your store? Did you experience missing orders, orders without owners as result of lacking good tracking system?
                                        </p>
                                        <p>
                                        Heli Together Strong can help you. Above troublesome will go away.
                                        </p>
                                    </div>
                                  </Typography>
                                </CardContent>
                              </CardActionArea>
                              <CardActions>
                                <Button variant="contained" size="large" color="primary" onClick={() => scrollToElement('download', -120)}>
                                  Get it now
                                </Button>
                              </CardActions>
                            </Card>
                        </Grid>
                        <Grid item xs={10}>
                            <Card>
                              <CardActionArea>
                                <CardMedia
                                  component="img"
                                  alt="Contemplative Reptile"
                                  height="350"
                                  image={coffee}
                                  title="Contemplative Reptile"
                                />
                                <CardContent>
                                  <Typography gutterBottom variant="h5" component="h2">
                                    合力
                                  </Typography>
                                  <Typography variant="body2" color="textSecondary" component="span">
                                    <div className="description_text">
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
                                            卖的轻松！
                                        </p>
                                    </div>
                                  </Typography>
                                </CardContent>
                              </CardActionArea>
                              <CardActions>
                                <Button variant="contained" size="large" color="primary" onClick={() => scrollToElement('download', -120)}>
                                  马上下载！
                                </Button>
                              </CardActions>
                            </Card>
                        </Grid>
                    </Grid>
                </div>
            </div>
        </Fade>

    );
}

export default Description;