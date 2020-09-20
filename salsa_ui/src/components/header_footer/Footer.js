import React, { Component } from 'react';
import Fade from 'react-reveal/Fade';

const Footer = () => {

    return (
        <footer className="bck_black">
            <Fade delay={500}>
                <div className="font_righteous footer_logo_venue">合力</div>
                <div className="footer_copyright">OUYANG SQUAD 2020. All rights reserved</div>
            </Fade>
        </footer>
    )
}

export default Footer;