import React, { Component } from 'react';
import { BrowserRouter as Router, Route, Link } from 'react-router-dom';
import './resources/styles.css';
import "slick-carousel/slick/slick.css";
import "slick-carousel/slick/slick-theme.css";
import { Element } from 'react-scroll';

import Header from './components/header_footer/Header';
import Featured from './components/featured';
import ProductInfo from './components/product_info';
import Highlight from './components/highlights';
import Download from './components/download';
import Footer from './components/header_footer/Footer'

class App extends Component {
  render() {
    return (
      <Router>
        <div className="App" style={{ height: "1500px" }}>
          <Header />
          <Element name="featured">
            <Featured />
          </Element>
          <Element name="description">
            <ProductInfo />
          </Element>
          <Element name="highlights">
            <Highlight />
          </Element>
          <Element name="download">
            <Download />
          </Element>
          <Footer />
        </div>
      </Router>
    );
  }
}

export default App;
