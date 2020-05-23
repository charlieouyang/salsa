import React, { Component } from 'react';
import Fade from 'react-reveal/Fade';
import Slide from 'react-reveal/Slide';
import MyButton from '../utils/MyButton';

class Discount extends Component {

    state = {
        discountStart: 0,
        discountEnd: 30
    }

    percentage = () => {
        if (this.state.discountStart < this.state.discountEnd) {
            this.setState({
                discountStart: this.state.discountStart + 1
            });
        }
    }

    componentDidUpdate() {
        setTimeout(() => {
            this.percentage();
        }, 30);
    }

    render() {
        return (
            <div className="center_wrapper">
                <div className="discount_wrapper">
                    <Fade
                        onReveal={() => this.percentage()}
                    >
                        <div className="discount_percentage">
                            <span>{this.state.discountStart}%</span>
                            <span>OFF</span>
                        </div>
                    </Fade>

                    <Slide right>
                        <div className="discount_description">
                            <h3>Purchase ticket before JUNE 20th</h3>
                            <p>Donec molestie quam ut ipsum tincidunt mattis. Suspendisse in tempus neque, vel pulvinar odio. Nunc nulla dolor, tristique sed metus gravida, dictum porttitor lectus. Donec non semper ante, vel condimentum arcu. Aliquam erat volutpat. Sed id augue convallis, aliquam orci nec, mattis lacus. Donec suscipit enim ullamcorper elit faucibus hendrerit. Nulla facilisi.</p>

                            <MyButton 
                                text="Purchase tickets"
                                bck="#ffa800"
                                color="#ffffff"
                                href="http://google.com"
                            />
                        </div>
                    </Slide>
                </div>
            </div>
        );
    }
}

export default Discount;