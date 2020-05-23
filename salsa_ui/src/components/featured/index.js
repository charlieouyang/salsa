import React, { Component } from 'react';
import Carrousel from './Carrousel';

const Featured = () => {
    return (
        <div style={{ position: 'relative' }}>
            <Carrousel />

            <div className="artist_name">
                <div className="wrapper">
                    HELISTRONG
                </div>
            </div>
        </div>
    )
}

export default Featured;