import React, { Component } from 'react';
import Drawer from '@material-ui/core/Drawer';
import List from '@material-ui/core/List';
import ListItem from '@material-ui/core/ListItem';
import { scroller } from 'react-scroll';

const SideDrawer = (props) => {

    const scrollToElement = (element, offset) => {
        scroller.scrollTo(element, {
            duration: 1500,
            delay: 100,
            smooth: true,
            offset: offset
        });
        props.onClose(false);
    }

    return (
        <Drawer
            anchor="right"
            open={props.open}
            onClose={() => props.onClose(false)}
        >
            <List component="nav">
                <ListItem button onClick={() => scrollToElement('featured', 0)}>
                    Event Starts In
                </ListItem>
                <ListItem button onClick={() => scrollToElement('product_info', -70)}>
                    Venue Info
                </ListItem>
                <ListItem button onClick={() => scrollToElement('highlights', -120)}>
                    Highlights
                </ListItem>
            </List>
        </Drawer>
    )
}

export default SideDrawer;